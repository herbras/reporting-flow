---
description: Start a Founderplus product cycle — turn a Pitch into Multica issues + git branch
argument-hint: "<pitch-name-or-link>"
---

# /cycle-start — Kick-off Cycle Tim Product

Kamu adalah orchestrator kick-off cycle. Tugas: ubah Pitch jadi (1) issue list di Multica, (2) branch git di repo kode. **Jangan koding** — ini fase Uphill (riset & planning).

Fizzy dorman. Jangan `fizzy card create`.

## Input

- `$ARGUMENTS` = nama pitch atau link Pitch (misal `hermes-validation-sprint` atau URL)

## Langkah

### 1. Konfirmasi Konteks
Tanya user (kecuali sudah jelas dari `$ARGUMENTS`):
- **Pitch apa?** Minta link atau ringkasan 2-3 kalimat (the "Why" + "What")
- **Repo kode mana?** Path absolut atau nama repo
- **Project Multica mana?** Jalankan `multica project list --output json` dan minta user pilih, atau buat project baru.
- **Siapa Technical PM?** (default Huda)

### 2. Verifikasi Setup
```bash
multica auth status
```
Server harus `https://pm.founderplus.id`, workspace `founderplus-product`.
Kalau gagal: arahkan user `multica login` lalu stop.

### 3. Riset Teknis (Uphill Work)
Sebelum buat issue, **wajib** riset dulu. Kalau repo kode besar:
- Spawn `Agent(subagent_type=Explore)` dengan prompt: "Riset codebase untuk pitch: <ringkasan>. Identifikasi modul terpengaruh, dependency, edge case, dan area risiko."
- Tunggu hasil. Hasil riset jadi bahan untuk pecah task.

### 4. Pecah Task — Aturan Granularity

**1 issue = 1 unit yang bisa di-ship & di-test sendiri.**

Pecah berdasarkan:
- Vertical slice (bisa di-demo)
- Boundary jelas (input/output kontrak)
- Bisa selesai 4 jam – 1 hari
- Jangan: "implement backend" (terlalu besar)
- Jangan: "rename variable X" (terlalu kecil — masuk di issue lain)

Target: 5–15 issue per cycle (6 minggu).

### 5. Buat Issue di Multica

Untuk setiap task, panggil:
```bash
multica issue create \
  --project <PROJECT_ID> \
  --title "<verb + outcome, e.g. 'Add validation endpoint for retention plan'>" \
  --description "Pitch: <link>. Acceptance: <criteria>." \
  --status todo
```

Capture `identifier` (FOUN-n) dari JSON untuk langkah berikutnya.

Issue anak, kalau perlu:
```bash
multica issue create --project <PROJECT_ID> --parent <PARENT_ID> --title "<subtask>" --status todo
```

### 6. Buat Branch Git

Di repo kode:
```bash
cd <repo-path>
git checkout main
git pull
git checkout -b cycle/<pitch-slug>
```

`<pitch-slug>` = slug kebab-case dari nama pitch (misal `hermes-validation-sprint`).

### 7. Buat Catatan Awal di Vault (Optional tapi Recommended)

Kalau Pitch ini cukup signifikan (cross-cutting, ada decision strategis), catat kick-off-nya:

```bash
cd ~/Documents/Founderplus/agent-changelog
```

Lalu panggil `/catat`:
```
Kick-off cycle <pitch-name>. Goal: <1 kalimat>.
Approach teknis: <hasil riset, 2-3 kalimat>.
Issues di Multica: FOUN-<n1>, FOUN-<n2>, ...
Estimasi cycle: <X minggu>.
```

Skip langkah ini untuk pitch kecil/maintenance.

### 8. Output ke User

Setelah selesai, tampilkan ringkasan:

```
Cycle <pitch-name> dimulai.

Multica:
  Project: <project-name>
  Issues: <count> dibuat
    FOUN-<n1> — <title>
    FOUN-<n2> — <title>
    ...

Git:
  Repo: <repo-path>
  Branch: cycle/<pitch-slug>

Vault:
  Catatan kick-off: <path raw/inbox/...> (atau "skipped")

Next:
  - Validasi task list dengan <Technical PM>
  - Mulai Uphill Work pada issue pertama
  - Update Multica + commit dengan format: <type>(<scope>): <msg>\n\nRefs: FOUN-<n>
```

## Aturan

- **JANGAN buat lebih dari 20 issue** dalam 1 cycle — itu signal granularity terlalu kecil atau pitch terlalu besar
- **JANGAN koding** di langkah ini — cuma planning
- **JANGAN buat branch sebelum issue Multica ada** — task list dulu, baru branch
- **JANGAN buka kartu Fizzy** — papan kerja adalah Multica
- **Konfirmasi semua nama** (project, PM, repo) sebelum eksekusi — jangan asumsi
- Kalau user belum punya Pitch tertulis, suruh tulis dulu (minimal 1 paragraf "Why" + "What") — jangan kick-off cycle dari ide verbal

## Referensi

- Skill orchestrator: `~/.claude/skills/founderplus-cycle/SKILL.md`
- Playbook: `~/Documents/Founderplus/agent-changelog/wiki/concepts/product/team-ops/02-playbook-operasional.md`
