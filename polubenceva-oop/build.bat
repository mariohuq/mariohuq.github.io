@chcp 1251 > nul

@pandoc "���� I.md" "���� II.md" "���� III.md" "���� IV.md" "���� V.md" "���� VI.md" "���� VII.md" "���� VIII.md" "���� IX.md" "���� X.md" "���� XI.md" "���� XII.md" "���� XIII.md" --standalone --fail-if-warnings --table-of-contents --highlight-style vs.theme -oindex.html && index.html || @pause