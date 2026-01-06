# RUST ESP-IDF

## Panduan instalasi

### Untuk linux debian dan turunannya

```
curl -fsSL https://raw.githubusercontent.com/harjitounnes/rust-esp32/main/deb-install.sh | bash
```


### Untuk Mac Intel dan turunannya

Pastikan sudah terinstall homebrew

```
curl -fsSL https://raw.githubusercontent.com/harjitounnes/rust-esp32/main/mac-install.sh | bash
```
## Memulai project
```
cargo generate esp-rs/esp-idf-template cargo
```
- Project name: [nama project]
- Pilih MCU: sesuai hardware yang digunakan
- Option:false

## Build project
``` 
cd [nama_project]
cargo build
```

## Demo

<p align="center">
  <a href="https://www.youtube.com/watch?v=FLCmosDO4fI">
    <img src="https://img.youtube.com/vi/FLCmosDO4fI/0.jpg" width="600">
  </a><br />
  <span>Klik Untuk tonton demo.</span>
</p>
