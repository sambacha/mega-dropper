def comment_align(s: str) -> int:
    return s.index('//')


def line(indent, comi, *comps):
    total_line = ''.join(comps)
    if comi is None:
        assert '//' not in total_line, 'Comment found'
        pre_comment = total_line.strip()
        comment = None
    else:
        pre_comment, comment = total_line.split('//', 1)
        pre_comment = pre_comment.strip()
        comment = comment.strip()

    indented = ' ' * (4 * indent) + pre_comment
    if comi is not None and len(indented) >= comi:
        raise ValueError(
            f'Line "{pre_comment}" too long for correct comment alignment'
        )

    if comi is not None:
        return indented + ' ' * (comi - len(indented)) + '// ' + comment
    else:
        return indented
