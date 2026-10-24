---
name: founderplus-cycle
description: |
  Orchestrate Founderplus product execution cycle (Shape Up methodology) across
  Multica (task tracking), Git (code), and the agent-changelog vault (knowledge
  base). Thin orchestrator — delegates to `multica` CLI for issue/project
  operations, to git for code, and to the vault's `/catat` + `/compile` slash
  commands for documentation. Use this skill when starting/shipping a cycle, or
  when the user needs guidance on where a piece of information belongs (Multica
  vs Git commit message vs vault). Fizzy is dormant — do not open or update
  Fizzy cards for cycle work.
triggers:
  - kick-off
  - kickoff
  - cycle start
  - mulai cycle
  - ship cycle
  - tutup cycle
  - close cycle
  - cycle ship
  - end of cycle
  - cycle done
  - founderplus workflow
  - workflow founderplus
  - pitch
  - hill chart
  - shape up
  - tim product
  - product engineer workflow
  - multica
invocable: true
argument-hint: "[start|ship|status] [pitch-name]"
---

# /founderplus-cycle — Orchestrator Cycle Tim Product

Skill ini **tidak** menggantikan tools yang sudah ada. Fungsinya menjahit:

- **Multica** (CLI `multica`) — issue, project, komentar. Workspace
  `founderplus-product` di https://pm.founderplus.id
- **Git** — branch, commit, PR di repo kode
- **agent-changelog vault** — knowledge base permanen via `/catat` & `/compile`
  - Vault path: `~/Documents/Founderplus/agent-changelog/`

**Fizzy dorman.** `fizzy` / app.fizzy.do bukan papan kerja. Driver webhook
Fizzy di `apps/api` adalah sisa support-ticket, bukan cycle.

## Prinsip Inti

1. **Pitch turun → eksekusi → ship → catat.** 4 fase. Jangan lompat.
2. **Sumber kebenaran berbeda per artefak:**
   - "Apa yang dikerjakan minggu ini" → Multica
   - "Diff kode" → Git
   - "Kenapa keputusan ini diambil 3 bulan lagi masih perlu diingat" → vault
3. **Diam = invisible.** Setiap stuck/keputusan teknis → komentar Multica. Setiap milestone/decision strategis → `/catat`.
4. **Granularity Multica:** 1 issue = 1 unit yang bisa di-ship & di-test sendiri. Target 3–5 issue kecil/hari.

## Decision Tree — "Ini ditaruh di mana?"

```
Informasi yang mau disimpan?
├── Status task harian / subtask / komentar teknis per issue
│   └── → Multica (komentar di issue, atau issue baru)
├── Diff kode / pesan commit
│   └── → Git (commit message singkat, Refs: FOUN-<n> kalau perlu)
├── Keputusan arsitektur / lesson learned / SOP / konsep baru
│   └── → vault via `/catat` (raw/inbox/) → nanti `/compile` ke wiki/
├── Update OKR / progress KR
│   └── → vault via `/skor {nama} KR{n} {value}`
└── Update KPI bulanan
    └── → vault: edit `metrics/{bidang}/YYYY-MM.csv` lalu `/compile`
```

## Fase 1 — Kick-off (Pitch turun)

PM (Huda) presentasi Pitch. Tanggung jawab Product Engineer:

- [ ] Baca Pitch pelan, catat pertanyaan
- [ ] Riset teknis (Uphill Work) — jangan langsung koding
  - Pakai agen di repo kode untuk eksplorasi
  - Spawn `Agent(subagent_type=Explore)` kalau repo besar
- [ ] Pecah jadi issue di Multica:
  - `multica auth status` dulu (server harus `https://pm.founderplus.id`)
  - `multica project list --output json` lalu pilih project, atau buat baru
  - `multica issue create --project <id> --title "..." --description "Pitch: <link>" --status todo`
- [ ] Validasi singkat task list dengan Technical PM
- [ ] Buat git branch di repo kode: `git checkout -b cycle/<pitch-slug>`

**Slash command pendukung:** `/cycle-start <pitch-name>` (lihat `~/.claude/commands/cycle-start.md`)

## Fase 2 — Eksekusi (Uphill → Downhill)

Selama cycle berjalan:

- Koding di repo
- **Setiap commit:** pesan jelas, format `<type>(<scope>): <summary>` + `Refs: FOUN-<n>`
- **Setiap perubahan status issue:**
  ```
  multica issue status FOUN-<n> in_progress   # atau in_review, blocked, done, cancelled
  ```
  Status sah: `backlog`, `todo`, `in_progress`, `in_review`, `done`, `blocked`, `cancelled`.
- **Setiap keputusan teknis non-trivial:** komentar di issue Multica
  ```
  multica issue comment add FOUN-<n> --content "Pakai approach X karena Y. Trade-off: Z."
  ```
- **Stuck > 1 hari** → tulis di issue, assign shepherd

## Fase 3 — Ship

Per fitur selesai:

- [ ] Test sendiri (kualitas = tanggung jawab pemilik fitur)
- [ ] Push branch, buat PR, tag reviewer
- [ ] Setelah merge: `multica issue status FOUN-<n> done`
- [ ] Kalau ini milestone signifikan (rilis, fitur user-facing, breaking change) → lanjut Fase 4

## Fase 4 — Catat ke Vault

Inilah langkah yang **paling sering bocor**. Tanpa ini, 3 bulan lagi tidak ada yang ingat kenapa keputusan diambil.

Yang **wajib** masuk vault:

| Kondisi | Aksi |
|---------|------|
| Fitur shipped | `/catat <ringkasan apa yang shipped, dampak, lesson>` |
| Keputusan arsitektur | `/catat <decision, alternatif yang ditolak, alasan>` |
| Update progress OKR/KR | `/skor <nama> KR<n> <value> <unit>` |
| Konsep baru / SOP lahir | `/catat` lalu nanti `/compile` akan generate `wiki/concepts/` atau `wiki/sop/` |
| Retrospective / lesson learned cycle | `/catat <apa yang belajar, apa yang akan diubah next cycle>` |

Yang **tidak perlu** masuk vault (tetap di Multica/Git):
- Diskusi harian per task
- Status issue bergerak
- Daftar subtask
- Diff kode mentah

**Cara catat:** buka working directory vault, jalankan Claude:
```bash
cd ~/Documents/Founderplus/agent-changelog
claude
# lalu di Claude:
/catat <konten>
```

Atau langsung dari sesi ini kalau working directory sudah di vault.

**Slash command pendukung:** `/cycle-ship <ringkasan>` (lihat `~/.claude/commands/cycle-ship.md`)

## Aturan Vault yang Sering Dilanggar

Saat memanggil `/catat` atau menulis ke vault, ingat constraint dari `CLAUDE.md` repo:

1. **JANGAN edit `wiki/` manual** — selalu lewat `raw/inbox/` (yang dilakukan `/catat`)
2. **JANGAN tulis nama individu** (Alfi, Slamet, Ardi, dll) di wiki publik — pakai role "Product Engineer". Huda OK karena Head.
3. **JANGAN fabricate angka** — kalau tidak punya bukti, tulis "belum terverifikasi" eksplisit
4. **NO emoji di section header wiki publik** — signal AI-slop
5. **NO ASCII box art** (┌─│└─) — pakai Mermaid. File tree (├──) OK.

## Workflow Visual

```mermaid
flowchart LR
    A[Pitch] --> B[Riset]
    B --> C[Issue list: Multica]
    C --> D[Branch: git checkout -b]
    D --> E[Code + Commit]
    E --> F[Update Multica: status + komentar]
    F --> G{Cycle done?}
    G -->|tidak| E
    G -->|ya| H[multica issue status done]
    H --> I{Milestone/decision penting?}
    I -->|ya| J[/catat ke vault/]
    I -->|tidak| K[End cycle]
    J --> L[/compile saat akhir minggu/]
    L --> K
```

## Mode Pemanggilan

- **Tanpa argumen:** tampilkan ringkasan + tanya user mau apa (start cycle / ship / status / explain)
- **`start <pitch-name>`:** delegasi ke `/cycle-start`
- **`ship <ringkasan>`:** delegasi ke `/cycle-ship`
- **`status`:** panggil `multica issue list --assignee "ibrahim" --status in_progress --output json` plus `--status blocked` dan `--status todo`

## Referensi

- Multica CLI: `multica --help` (auth: `multica auth status`; login: `multica login`)
- Vault CLAUDE.md: `~/Documents/Founderplus/agent-changelog/CLAUDE.md`
- Team Ops Playbook: `~/Documents/Founderplus/agent-changelog/wiki/concepts/product/team-ops/`
- Slash commands: `~/.claude/commands/cycle-start.md`, `~/.claude/commands/cycle-ship.md`
