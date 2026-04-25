---
description: Close a Founderplus cycle — close Fizzy cards + draft vault entry for what's worth remembering
argument-hint: "<ringkasan apa yang shipped>"
---

# /cycle-ship — Tutup Cycle & Catat ke Vault

Kamu adalah orchestrator close-out cycle. Tugas: pastikan (1) Fizzy bersih, (2) hal-hal yang penting tercatat di vault. **Bukan** menulis untuk public — kamu cuma draft entry mentah ke `raw/inbox/` lewat `/catat`.

## Input

- `$ARGUMENTS` = ringkasan singkat apa yang shipped (1-3 kalimat)

## Langkah

### 1. Konfirmasi Konteks
Tanya kalau belum jelas:
- **Cycle apa yang ditutup?** (nama pitch / branch git)
- **Cards Fizzy yang relevan?** (kalau user tidak sebut, jalankan langkah 2 untuk discover)

### 2. Audit Status Fizzy

Tampilkan kartu yang masih open di branch/cycle ini:
```bash
fizzy card list --assignee me --indexed-by not_now,stalled --jq '[.data[] | {number, title, column}]'
```

Untuk setiap kartu yang **belum** closed, tanya user:
- ✅ Sudah selesai → `fizzy card close <num>`
- ⏸ Belum selesai, carry over ke cycle berikutnya → biarkan, tapi catat di entry vault
- ❌ Tidak jadi dikerjakan → `fizzy card postpone <num>` atau close dengan komentar alasan

### 3. Audit Status Git

```bash
git log --oneline <main>..HEAD  # lihat commit di cycle branch
git status                       # cek ada yang belum di-commit
```

Kalau masih ada uncommitted: stop, suruh user commit/stash dulu.
Kalau branch belum di-merge ke main: konfirmasi PR sudah merged sebelum lanjut.

### 4. Filter — Apa yang Layak Masuk Vault?

**Wajib catat:**
- ✅ Fitur user-facing yang shipped (apa, siapa user, dampak)
- ✅ Keputusan arsitektur (decision, alternatif yang ditolak, alasan)
- ✅ Breaking change atau migrasi
- ✅ Konsep/SOP/pattern baru yang lahir dari cycle ini
- ✅ Lesson learned yang akan mempengaruhi cycle berikutnya
- ✅ Update OKR/KR yang bergerak

**Tidak perlu catat (sudah ada di Fizzy/Git):**
- ❌ Daftar commit
- ❌ Daftar kartu yang dipindah antar kolom
- ❌ Diskusi teknis per task
- ❌ Bug minor yang sudah closed di Fizzy

### 5. Susun Draft Entry

Format draft (1 entry = 1 topik — kalau ada 3 hal berbeda, buat 3 entry):

```
Cycle <pitch-name> selesai (<tanggal mulai> - <tanggal selesai>).

Yang shipped:
- <fitur 1, dampak singkat>
- <fitur 2, dampak singkat>

Keputusan penting:
- <decision X> — alasan: <Y>. Alternatif yang ditolak: <Z>.

Lesson:
- <apa yang belajar>
- <apa yang akan diubah cycle berikutnya>

OKR/KR yang bergerak:
- <KR-X> dari <old> ke <new>

Carry over ke cycle berikutnya:
- <kartu Fizzy #N — alasan>
```

### 6. Pindah ke Working Directory Vault

Vault path: `~/Documents/Founderplus/agent-changelog/`

Kalau current directory bukan vault:
```bash
cd ~/Documents/Founderplus/agent-changelog
```

### 7. Panggil `/catat`

Untuk setiap topik dalam draft, panggil `/catat` dengan konten yang sudah disusun. `/catat` akan:
- Identifikasi `division` (default: `product` untuk cycle Product Engineer)
- Identifikasi `type` (default: `milestone` untuk ship event, `decision` untuk keputusan, `experiment` untuk lesson)
- Buat file di `raw/inbox/YYYY-MM-DD_product_<slug>.md` dengan frontmatter sesuai SCHEMA.md

**Aturan saat memanggil `/catat`:**
- **JANGAN** sebut nama Product Engineer individual (Alfi/Slamet/Ardi) — pakai role "Product Engineer". Huda OK.
- **JANGAN** fabricate angka — kalau tidak yakin (impact, jumlah user, dll), tulis "belum terverifikasi"
- **JANGAN** copy-paste commit messages mentah — itu sudah ada di git
- Bahasa Indonesia, fakta bukan opini

### 8. Update OKR (jika applicable)

Kalau cycle ini bergerakkan KR, panggil `/skor`:
```
/skor <nama> KR<n> <value> <unit-singkat>
```

Contoh: `/skor huda KR2 0.6 6 dari 10 fitur shipped`

### 9. Cek Apakah Compile Diperlukan

`/catat` hanya tulis ke `raw/inbox/`. Untuk publish ke `wiki/`, perlu `/compile`.

Tanya user:
- Mau langsung `/compile` sekarang? (recommended kalau ini akhir minggu/sprint)
- Atau biarkan dulu sampai compile rutin?

### 10. Output Akhir

```
Cycle <pitch-name> closed.

Fizzy:
  Cards closed: <N>
  Carry over: <M> kartu (<list nomor>)

Git:
  Branch: <branch-name> merged ke main

Vault entries created:
  <path 1>
  <path 2>
  ...

OKR updates:
  <KR-X>: <old> → <new>

Next:
  - Compile vault: /compile (atau biarkan ke compile rutin)
  - Retro 1-on-1 dengan Technical PM
  - Mulai cycle berikutnya: /cycle-start <next-pitch>
```

## Aturan

- **JANGAN tulis langsung ke `wiki/`** — selalu lewat `/catat` ke `raw/inbox/`
- **JANGAN catat hal yang sudah ada di Fizzy/Git** — vault buat memori jangka panjang, bukan duplikat
- **Konfirmasi setiap entry** sebelum `/catat` execute — preview dulu
- Kalau cycle gagal/aborted, tetap catat — lesson dari kegagalan sama berharganya
- Kalau ragu apakah suatu hal layak dicatat: tanya "3 bulan lagi orang masih perlu tahu ini?" Kalau ya → catat. Kalau tidak → skip.

## Referensi

- Skill orchestrator: `~/.claude/skills/founderplus-cycle/SKILL.md`
- `/catat`: `~/Documents/Founderplus/agent-changelog/.claude/commands/catat.md`
- `/skor`: `~/Documents/Founderplus/agent-changelog/.claude/commands/skor.md`
- `/compile`: `~/Documents/Founderplus/agent-changelog/.claude/commands/compile.md`
- Anti-halusinasi rules: `~/Documents/Founderplus/agent-changelog/CLAUDE.md` bagian "Anti-Halusinasi — Protokol Ketat"
