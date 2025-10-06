# Tang Nano 20K – Blink con toolchain open source

Proyecto mínimo para Sipeed Tang Nano 20K usando herramientas open source (OSS CAD Suite + Apicula): síntesis, place&route y programación.

---

## Requisitos

- OSS CAD Suite en el PATH (incluye `yosys`, `nextpnr-himbaechel`, `gowin_pack`).
- `openFPGALoader` para programar la placa.

Descargas: [OSS CAD Suite releases](https://github.com/YosysHQ/oss-cad-suite-build/releases)

En WSL2 compartir el USB desde Windows a Linux con `usbipd`.

---

## Instalación (paso a paso)

### Linux (Ubuntu/Debian)

1. Bajá el paquete precompilado de OSS CAD Suite de la página de releases y descomprimilo en tu home.

```bash
tar -xf oss-cad-suite-linux-x64-<fecha>.tgz -C ~/
echo 'export PATH=$HOME/oss-cad-suite/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

2. Verificá herramientas:

```bash
yosys -V
nextpnr-himbaechel --version
gowin_pack -h | head -n 1
openFPGALoader --version
```

### Windows + WSL2 (pasar USB FTDI al Linux del WSL)

1. Instalá el driver FTDI VCP en Windows si no lo reconoce:

- [FTDI VCP Drivers](https://ftdichip.com/drivers/vcp-drivers/)

2. En PowerShell o CMD (Administrador), listá y vinculá el dispositivo FTDI:

```powershell
usbipd list                         # ver BUSID del FTDI (0403:6010)
usbipd bind --b <BUSID>           	# primera vez, asocia el dispositivo a usbipd
usbipd attach -a -b <BUSID> -w      # adjunta al WSL actual y reconecta automáticamente en casso de desconexión del USB
```

3. En Ubuntu/WSL2 verificá que el dispositivo esté visible con alguno de los comandos siguientes:

```bash
lsusb                  
ls /dev/ttyUSB*        
openFPGALoader --detect
```

---

## Estructura

```text
.
├── Makefile
├── README.md
├── src/
│   └── blinky.v
├── constraints/
│   └── tangnano20k.cst
├── build/   # generado: JSON de síntesis y P&R
└── bit/     # generado: bitstream .fs
```

---

## Uso rápido

Compilar y generar bitstream:

```bash
make bit
```

Programar la FPGA:

```bash
make flash
```

Limpiar artefactos:

```bash
make clean
```

---

## Targets disponibles

- `all` → alias de `bit`.
- `synth` → genera `build/blinky_synth.json` (Yosys).
- `pnr` → genera `build/blinky_pnr.json` (nextpnr, usa `constraints/tangnano20k.cst`).
- `pack` → genera `bit/blinky.fs` (gowin_pack).
- `flash` → programa la FPGA con `openFPGALoader -b tangnano20k bit/blinky.fs`.
- `dirs` → crea carpetas requeridas.
- `clean` → borra `build/` y `bit/`.

Make es incremental: sólo recompila lo necesario.

---

## Notas

- Artefactos generados viven en `build/` y `bit/`.
- Para otra placa (p. ej. Tang Nano 9K) cambiá `DEVICE` y `FAMILY` en el Makefile y conservá el flujo.

---

## Solución de problemas (FAQ)

- No se encuentra una herramienta (p. ej. `nextpnr-himbaechel: command not found`):
  - Asegurate de haber agregado `$HOME/oss-cad-suite/bin` al `PATH` y de haber hecho `source ~/.bashrc`.
  - Verificá versiones con:

    ```bash
    which yosys && yosys -V
    which nextpnr-himbaechel && nextpnr-himbaechel --version
    which gowin_pack && gowin_pack -h | head -n 1
    which openFPGALoader && openFPGALoader --version
    ```

- `make bit` falla por constraints o pines:
  - Revisá `constraints/tangnano20k.cst` (nombres de puertos deben coincidir con los del módulo top).
  - Confirmá que el módulo top es `blinky` y que `TOP := blinky` en el `Makefile`.

- `openFPGALoader` no detecta el dispositivo:
  - En WSL2: reintentá `usbipd attach -a -b <BUSID> -w` y corré `openFPGALoader --detect`.
  - Probá con permisos: `sudo openFPGALoader --detect` (o configurá reglas udev si querés evitar sudo).

- La compilación no se actualiza cuando cambio el HDL:
  - `make clean` para forzar recompilar desde cero.
  - Verificá que estás editando `src/blinky.v` y no otro archivo.

- Quiero ver más detalle del flujo:
  - Ejecutá etapas por separado: `make synth`, `make pnr`, `make pack`.
  - Agregá `-v`/`-d` según la herramienta (ver help de cada una).

---

## Licencia

Este proyecto está bajo licencia MIT. Ver el archivo [LICENSE](./LICENSE).

