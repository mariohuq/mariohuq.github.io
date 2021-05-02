@chcp 1251 > nul

@pandoc "义爨 I.md" "义爨 II.md" "义爨 III.md" "义爨 IV.md" "义爨 V.md" "义爨 VI.md" "义爨 VII.md" "义爨 VIII.md" "义爨 IX.md" "义爨 X.md" "义爨 XI.md" "义爨 XII.md" "义爨 XIII.md" --standalone --fail-if-warnings --table-of-contents --highlight-style vs.theme -oindex.html && index.html || @pause