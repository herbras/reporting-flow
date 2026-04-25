# reporting-flow

Claude Code skill + slash commands + subagent untuk workflow execution cycle tim Product Founderplus.

Mengikat tiga sumber kebenaran yang sudah ada:

- **[Fizzy](https://fizzy.do)** (Basecamp) — task tracking via [`fizzy-cli`](https://github.com/basecamp/fizzy-cli)
- **Git** — kode + branch + commit
- **agent-changelog vault** — knowledge base permanen via slash commands `/catat`, `/compile`, `/skor`

Bukan untuk menggantikan tools tersebut. Ini orchestrator tipis yang membantu (1) tahu mana informasi ditaruh dimana, (2) menjalankan kick-off & ship cycle dengan kontrak yang konsisten.

## Apa yang ada

| Path | Tipe | Trigger |
|------|------|---------|
| `skills/founderplus-cycle/SKILL.md` | Skill (auto-trigger) | Kata kunci: "kick-off", "ship cycle", "shape up", "pitch", dll |
| `commands/cycle-start.md` | Slash command | `/cycle-start <pitch-name>` |
| `commands/cycle-ship.md` | Slash command | `/cycle-ship <ringkasan>` |
| `agents/cycle-coordinator.md` | Subagent | Dipanggil parent via `Agent(subagent_type=cycle-coordinator)` untuk audit cycle multi-source |

## Prasyarat

- [Claude Code](https://claude.com/claude-code)
- [`fizzy-cli`](https://github.com/basecamp/fizzy-cli) ter-install dan ter-auth (`fizzy doctor` lulus)
- Skill resmi Fizzy ter-install: `fizzy setup claude` (skill ini delegasi ke skill Fizzy untuk operasi card/board)
- Vault `agent-changelog` di `~/Documents/Founderplus/agent-changelog/` (atau adjust path di `SKILL.md`)

## Install

```bash
git clone git@github.com:herbras/reporting-flow.git
cd reporting-flow
./install.sh
```

Installer akan symlink:

```
~/.claude/skills/founderplus-cycle  →  <repo>/skills/founderplus-cycle
~/.claude/commands/cycle-start.md   →  <repo>/commands/cycle-start.md
~/.claude/commands/cycle-ship.md    →  <repo>/commands/cycle-ship.md
~/.claude/agents/cycle-coordinator.md →  <repo>/agents/cycle-coordinator.md
```

Symlink approach berarti `git pull` di repo ini langsung update skill yang aktif — tidak perlu re-install.

## Uninstall

```bash
./install.sh --uninstall
```

Hapus symlink saja, file di repo tetap ada.

## Cara Pakai

### Trigger otomatis (skill)

Ketik di Claude Code apa saja yang menyebut workflow cycle:

> "besok mau kick-off cycle hermes phase 5b, gimana mulainya?"

Claude akan invoke skill `founderplus-cycle` dan memandu sesuai prinsip Shape Up + protokol vault Founderplus.

### Slash command — kick-off

```
/cycle-start hermes-validation-sprint
```

Output:
1. Verifikasi `fizzy doctor`
2. Riset codebase (spawn `Agent(Explore)` kalau perlu)
3. Pecah task list di Fizzy
4. Buat git branch `cycle/hermes-validation-sprint`
5. (Optional) catatan kick-off ke vault

### Slash command — ship

```
/cycle-ship phase 5a shipped, 3 endpoint validation, retention plan jadi draft
```

Output:
1. Audit kartu Fizzy yang masih open
2. Audit git (commits unmerged, uncommitted state)
3. Filter apa yang layak masuk vault
4. Draft entry → panggil `/catat`
5. Update OKR via `/skor` kalau ada KR yang bergerak

### Subagent — cycle audit

Untuk audit multi-source pertengahan cycle (read-only):

> "audit cycle hermes — apa yang masih open di Fizzy, apa yang unmerged di git, apa yang belum ter-dokumentasi di vault?"

Parent agent akan invoke subagent `cycle-coordinator` yang return punch-list.

## Filosofi: Thin Orchestrator

Skill ini sengaja **tidak**:

- ❌ Re-implement command Fizzy (delegasi ke skill resmi `fizzy`)
- ❌ Wrap `/catat` atau `/compile` (panggil apa adanya)
- ❌ Otomasi git commit (parent agent yang putuskan)
- ❌ Validasi schema vault (vault punya `scripts/lint-vault.py` sendiri)

Tujuan: kalau salah satu komponen update (Fizzy CLI release baru, vault skema berubah), repo ini tidak perlu ikut update — cuma tahu cara delegasi.

## Konvensi Commit Pesan

Kalau cycle pakai workflow ini, pesan commit sebaiknya ikut format:

```
<type>(<scope>): <summary>

<optional body>

Refs: fizzy/<card-number>
```

Subagent `cycle-coordinator` akan grep pola `Refs: fizzy/<n>` saat audit untuk mencocokkan commit ↔ kartu.

## Troubleshooting

- **Skill tidak ke-trigger?** Cek `ls -la ~/.claude/skills/founderplus-cycle` — harus symlink ke repo. Restart Claude Code.
- **`/cycle-start` tidak muncul di slash menu?** Beberapa build Claude Code hanya load slash command project-level. Copy ke `.claude/commands/` di repo kode yang sedang aktif (jangan symlink — beberapa build tidak follow symlink di project scope).
- **`fizzy` skill conflict?** Skill ini tidak override skill `fizzy` resmi — keduanya bisa hidup berdampingan. Kalau bentrok keyword, prioritas ada di skill yang lebih spesifik.
- **Path vault beda?** Edit `SKILL.md` & `commands/*.md` — ganti `~/Documents/Founderplus/agent-changelog/` ke path kamu.

## Roadmap (mungkin, kalau ada kebutuhan)

- [ ] Hook `PostToolUse` untuk auto-update Fizzy card status saat git commit
- [ ] `/cycle-status` — daily standup helper
- [ ] Template `.fizzy.yaml` untuk repo baru
- [ ] Integrasi Hill Chart update otomatis dari progress kartu

## Lisensi

MIT — pakai bebas.
