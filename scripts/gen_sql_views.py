#!/usr/bin/env python3
"""Write one indented SQL file per view from a three-column CSV export.

Column 2 is the view name and becomes the file name. Column 3 is the view
definition. Quoted fields may span lines; each CSV record is one view.

Usage:
    python beautify_sql_views.py CSV_PATH [OUTPUT_DIR]

OUTPUT_DIR defaults to the current working directory.
"""

from __future__ import annotations

import argparse
import csv
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

# Longer phrases are tried first so "left outer join" wins over "left join".
_BODY_CLAUSES = (
    "full outer join",
    "left outer join",
    "right outer join",
    "inner join",
    "left join",
    "right join",
    "full join",
    "cross apply",
    "outer apply",
    "cross join",
    "group by",
    "order by",
    "partition by",
    "for xml",
    "select",
    "from",
    "where",
    "having",
    "pivot",
    "unpivot",
    "join",
    "with",
)
_FLAT_CLAUSES = (
    "union all",
    "union",
    "except",
    "intersect",
    "create",
    "alter",
    "insert",
    "update",
    "delete",
    "view",
    "as",
)
# Newlines are inserted only before structural words. AND / OR / ON stay on
# the line the export already gave them, then indentation lines them up.
_BREAK_PHRASES = tuple(
    sorted(
        _BODY_CLAUSES
        + (
            "union all",
            "union",
            "except",
            "intersect",
            "case",
            "when",
            "else",
            "end",
        ),
        key=len,
        reverse=True,
    )
)

_INVALID_FILENAME = re.compile(r'[<>:"/\\|?*\x00-\x1f]')


def beautify_sql(sql: str) -> str:
    """Return sql with clause breaks and 4-space indentation.

    Non-whitespace characters are left unchanged.
    """
    return _indent(_break_before_keywords(sql.replace("\r\n", "\n").replace("\r", "\n")))


def _is_ident_char(char: str) -> bool:
    return char.isalnum() or char in "_@#"


def _left_boundary(sql: str, index: int) -> bool:
    if index == 0:
        return True
    return not _is_ident_char(sql[index - 1])


def _match_phrase(sql: str, index: int, phrase: str) -> int | None:
    parts = phrase.split(" ")
    pos = index
    length = len(sql)
    for part_index, part in enumerate(parts):
        end = pos + len(part)
        if sql[pos:end].lower() != part:
            return None
        pos = end
        if part_index == len(parts) - 1:
            break
        if pos >= length or sql[pos] not in " \t":
            return None
        while pos < length and sql[pos] in " \t":
            pos += 1
    if pos < length and _is_ident_char(sql[pos]):
        return None
    return pos


def _match_any(sql: str, index: int, phrases: tuple[str, ...]) -> int | None:
    for phrase in phrases:
        end = _match_phrase(sql, index, phrase)
        if end is not None:
            return end
    return None


def _break_before_keywords(sql: str) -> str:
    out: list[str] = []
    pending: list[str] = []
    index = 0
    length = len(sql)
    line_has_content = False

    def flush_pending() -> None:
        if pending:
            out.append("".join(pending))
            pending.clear()

    while index < length:
        if sql[index] == "'":
            end = _skip_quoted(sql, index, "'")
            flush_pending()
            out.append(sql[index:end])
            line_has_content = _tail_has_content(sql[index:end])
            index = end
            continue
        if sql[index] == '"':
            end = _skip_quoted(sql, index, '"')
            flush_pending()
            out.append(sql[index:end])
            line_has_content = _tail_has_content(sql[index:end])
            index = end
            continue
        if sql[index] == "[":
            end = _skip_bracket(sql, index)
            flush_pending()
            out.append(sql[index:end])
            line_has_content = _tail_has_content(sql[index:end])
            index = end
            continue
        if sql.startswith("--", index):
            end = _line_end(sql, index)
            flush_pending()
            out.append(sql[index:end])
            line_has_content = not sql[index:end].endswith("\n")
            index = end
            continue
        if sql.startswith("/*", index):
            end = sql.find("*/", index + 2)
            end = length if end < 0 else end + 2
            flush_pending()
            out.append(sql[index:end])
            line_has_content = _tail_has_content(sql[index:end])
            index = end
            continue
        if sql[index] in "\r\n":
            pending.clear()
            if sql[index] == "\r" and index + 1 < length and sql[index + 1] == "\n":
                index += 2
            else:
                index += 1
            out.append("\n")
            line_has_content = False
            continue
        if sql[index] in " \t":
            pending.append(sql[index])
            index += 1
            continue

        phrase_end = None
        if (
            sql[index].isalpha()
            and _left_boundary(sql, index)
            and (index == 0 or sql[index - 1] != ".")
        ):
            phrase_end = _match_any(sql, index, _BREAK_PHRASES)
        if phrase_end is not None:
            # Consume the whole phrase (INNER JOIN, not JOIN alone). Insert a
            # break only when the phrase does not already start the line.
            if line_has_content:
                pending.clear()
                out.append("\n")
            else:
                flush_pending()
            out.append(sql[index:phrase_end])
            index = phrase_end
            line_has_content = True
            continue

        flush_pending()
        out.append(sql[index])
        index += 1
        line_has_content = True

    flush_pending()
    return "".join(out)


def _tail_has_content(chunk: str) -> bool:
    last_nl = chunk.rfind("\n")
    tail = chunk if last_nl < 0 else chunk[last_nl + 1 :]
    return tail.strip(" \t\r") != ""


def _line_end(sql: str, index: int) -> int:
    end = index
    length = len(sql)
    while end < length and sql[end] not in "\r\n":
        end += 1
    if end < length and sql[end] == "\r":
        end += 1
    if end < length and sql[end] == "\n":
        end += 1
    return end


def _skip_quoted(sql: str, index: int, quote: str) -> int:
    index += 1
    length = len(sql)
    while index < length:
        if sql[index] == quote:
            if index + 1 < length and sql[index + 1] == quote:
                index += 2
                continue
            return index + 1
        index += 1
    return length


def _skip_bracket(sql: str, index: int) -> int:
    index += 1
    length = len(sql)
    while index < length:
        if sql[index] == "]":
            if index + 1 < length and sql[index + 1] == "]":
                index += 2
                continue
            return index + 1
        index += 1
    return length


@dataclass
class _State:
    paren_stack: list[int] = field(default_factory=list)
    body_stack: list[int] = field(default_factory=lambda: [0])
    case_stack: list[int] = field(default_factory=list)
    in_quote: str | None = None
    in_block: bool = False


def _indent(sql: str) -> str:
    state = _State()
    lines_out: list[str] = []
    previous_spaces = 0
    anchor_orig = 0
    anchor_spaces = 0

    for raw_line in sql.splitlines():
        if state.in_quote:
            lines_out.append(raw_line)
            previous_spaces = _orig_col(raw_line)
            _scan_line(raw_line, state, previous_spaces // 4, 0, False, False)
            continue

        if raw_line.strip() == "" and not state.in_block:
            lines_out.append("")
            continue

        was_block = state.in_block
        visible, _ = _visible_code(raw_line.strip(), state.in_block)
        kind = _classify(visible) if visible is not None else "comment"
        level = _indent_level(kind, visible or "", state)
        spaces = max(level, 0) * 4

        if kind == "comment" and was_block:
            spaces = max(0, anchor_spaces + _orig_col(raw_line) - anchor_orig)
        elif kind == "comment":
            spaces = previous_spaces

        stripped = raw_line.strip()
        lines_out.append((" " * spaces + stripped) if stripped else "")
        if stripped:
            previous_spaces = spaces

        if kind == "major_body":
            state.body_stack[-1] = 1
        elif kind == "case":
            state.case_stack.append(level)

        _scan_line(
            stripped,
            state,
            level,
            _leading_closes(visible or ""),
            kind == "case",
            kind == "end",
        )
        if not was_block and state.in_block:
            anchor_orig = _orig_col(raw_line)
            anchor_spaces = spaces

    while lines_out and lines_out[0] == "":
        lines_out.pop(0)
    while lines_out and lines_out[-1] == "":
        lines_out.pop()
    return "\n".join(lines_out) + "\n"


def _case_floor(state: _State) -> int:
    """Indent of an expression continued inside the current CASE."""
    if not state.case_stack:
        return 0
    return state.case_stack[-1] + 2


def _indent_level(kind: str, visible: str, state: _State) -> int:
    context = 0 if not state.paren_stack else state.paren_stack[-1] + 1
    body = context + state.body_stack[-1]
    if kind == "close":
        chosen = 0
        for _ in range(_leading_closes(visible)):
            if not state.paren_stack:
                break
            chosen = state.paren_stack.pop()
            if len(state.body_stack) > 1:
                state.body_stack.pop()
        return chosen
    if kind == "end":
        if state.case_stack:
            return state.case_stack.pop()
        return body
    if kind == "case":
        if state.case_stack:
            return state.case_stack[-1] + 2
        return body
    if kind == "when":
        if state.case_stack:
            return state.case_stack[-1] + 1
        return context + 1
    if kind == "logic":
        return max(context + 1, _case_floor(state))
    if kind in {"major", "major_body"}:
        return context
    return max(body, _case_floor(state))


def _classify(visible: str) -> str:
    if not visible:
        return "comment"
    if visible[0] == ")":
        return "close"
    if _match_phrase(visible, 0, "case") is not None:
        return "case"
    if _match_any(visible, 0, ("when", "then", "else")) is not None:
        return "when"
    if _match_phrase(visible, 0, "end") is not None:
        return "end"
    if _match_any(visible, 0, ("and", "or", "on")) is not None:
        return "logic"
    if _match_any(visible, 0, _BODY_CLAUSES) is not None:
        return "major_body"
    if _match_any(visible, 0, _FLAT_CLAUSES) is not None:
        return "major"
    return "body"


def _visible_code(text: str, in_block: bool) -> tuple[str | None, bool]:
    index = 0
    length = len(text)
    while index < length:
        if in_block:
            end = text.find("*/", index)
            if end < 0:
                return None, True
            index = end + 2
            in_block = False
            continue
        if text[index] in " \t":
            index += 1
            continue
        if text.startswith("--", index):
            return None, False
        if text.startswith("/*", index):
            in_block = True
            index += 2
            continue
        return text[index:], False
    return None, in_block


def _leading_closes(text: str) -> int:
    count = 0
    index = 0
    while index < len(text):
        if text[index] in " \t":
            index += 1
            continue
        if text[index] == ")":
            count += 1
            index += 1
            continue
        break
    return count


def _orig_col(line: str) -> int:
    column = 0
    for char in line:
        if char == " ":
            column += 1
        elif char == "\t":
            column = (column // 4 + 1) * 4
        else:
            break
    return column


def _scan_line(
    text: str,
    state: _State,
    line_level: int,
    skip_closes: int,
    skip_case: bool,
    skip_end: bool,
) -> None:
    index = 0
    length = len(text)
    while index < length:
        if state.in_quote:
            if text[index] == state.in_quote:
                if index + 1 < length and text[index + 1] == state.in_quote:
                    index += 2
                    continue
                state.in_quote = None
                index += 1
                continue
            index += 1
            continue
        if state.in_block:
            if text.startswith("*/", index):
                state.in_block = False
                index += 2
                continue
            index += 1
            continue
        if text.startswith("--", index):
            return
        if text.startswith("/*", index):
            state.in_block = True
            index += 2
            continue
        char = text[index]
        if char == "'":
            state.in_quote = "'"
            index += 1
            continue
        if char == '"':
            state.in_quote = '"'
            index += 1
            continue
        if char == "[":
            index = _skip_bracket(text, index)
            continue
        if char == "(":
            state.paren_stack.append(line_level)
            state.body_stack.append(0)
            index += 1
            continue
        if char == ")":
            if skip_closes:
                skip_closes -= 1
            else:
                if state.paren_stack:
                    state.paren_stack.pop()
                if len(state.body_stack) > 1:
                    state.body_stack.pop()
            index += 1
            continue
        if char.isalpha() and _left_boundary(text, index):
            case_end = _match_phrase(text, index, "case")
            if case_end is not None:
                if skip_case:
                    skip_case = False
                else:
                    state.case_stack.append(line_level)
                index = case_end
                continue
            end_end = _match_phrase(text, index, "end")
            if end_end is not None:
                if skip_end:
                    skip_end = False
                else:
                    if state.case_stack:
                        state.case_stack.pop()
                index = end_end
                continue
        index += 1


def load_views(csv_path: Path) -> list[tuple[str, str]]:
    with csv_path.open(newline="", encoding="utf-8-sig") as handle:
        views: list[tuple[str, str]] = []
        for record_no, row in enumerate(csv.reader(handle), start=1):
            if len(row) < 3:
                raise SystemExit(
                    f"{csv_path}: record {record_no} has {len(row)} columns, expected at least 3"
                )
            view_name = row[1].strip()
            view_ddl = row[2]
            if record_no == 1 and view_name.lower() == "view_name":
                continue
            if not view_name:
                raise SystemExit(f"{csv_path}: record {record_no} has an empty view name")
            if not view_ddl.strip():
                raise SystemExit(
                    f"{csv_path}: record {record_no} ({view_name}) has an empty view definition"
                )
            views.append((view_name, view_ddl))
    if not views:
        raise SystemExit(f"{csv_path}: no views found")
    return views


def sql_path(output_dir: Path, view_name: str) -> Path:
    if (
        view_name in {".", ".."}
        or _INVALID_FILENAME.search(view_name)
        or view_name != Path(view_name).name
    ):
        raise SystemExit(f"view name cannot be used as a file name: {view_name}")
    return output_dir / f"{view_name}.sql"


def write_views(views: list[tuple[str, str]], output_dir: Path) -> int:
    seen: dict[str, str] = {}
    for view_name, _ in views:
        key = view_name.casefold()
        if key in seen:
            raise SystemExit(f"duplicate view name: {seen[key]} and {view_name}")
        seen[key] = view_name

    if output_dir.exists() and not output_dir.is_dir():
        raise SystemExit(f"output path is not a directory: {output_dir}")
    output_dir.mkdir(parents=True, exist_ok=True)

    for view_name, view_ddl in views:
        sql_path(output_dir, view_name).write_text(beautify_sql(view_ddl), encoding="utf-8")
    return len(views)


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv_path", type=Path, help="CSV with schema, view name, and view SQL")
    parser.add_argument(
        "output_path",
        nargs="?",
        type=Path,
        help="directory for the .sql files (default: current directory)",
    )
    args = parser.parse_args(argv)
    if not args.csv_path.is_file():
        raise SystemExit(f"csv file not found: {args.csv_path}")
    output_dir = args.output_path if args.output_path is not None else Path.cwd()
    count = write_views(load_views(args.csv_path), output_dir)
    print(f"wrote {count} sql files to {output_dir}")


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        sys.exit(0)
