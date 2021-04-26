---
title: "Gentoo en NUC: Iniciar la instalación"
date: "2014-10-23"
categories: 
  - "gentoo"
tags: 
  - "linux"
  - "nuc"
---

Nota: Este post pertenece a una "colección", así que te recomiendo que empieces por la instalación [Gentoo GNU/Linux en un Intel® NUC D54250WYK](https://www.luispa.com/?p=7). En este artículo en concreto describo cómo iniciar el proceso de instalación arrancando desde una USB

# Boot con USB de instalación

Insertamos la USB que hemos creado en el paso anterior, arrancamos el equipo y pulsamos F10 para hacer boot desde la misma.

**Nota**: la primera vez que arranques el NUC y como no tienes todavía instalado el SSD, solo podrá hacer boot desde la USB.

[![boot0](https://www.luispa.com/wp-content/uploads/2014/12/boot0-1024x187.png)](https://www.luispa.com/wp-content/uploads/2014/12/boot0.png)

Una vez que aparezca el prompt de arranque pulsar TAB para ver las opciones disponibles, en nuestro caso escribimos "gentoo" y pulsamos Intro, veremos algo parecido a lo siguiente.

**Nota**: Cuando te pregunte el código de teclado usa "13" para Español

[![boot1_0_o](https://www.luispa.com/wp-content/uploads/2014/12/boot1_0_o.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/boot1_0_o.jpg) [![boot2_1_o](https://www.luispa.com/wp-content/uploads/2014/12/boot2_1_o.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/boot2_1_o.jpg) [![boot3_1_o](https://www.luispa.com/wp-content/uploads/2014/12/boot3_1_o.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/boot3_1_o.jpg) [![boot4_0_o](https://www.luispa.com/wp-content/uploads/2014/12/boot4_0_o.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/boot4_0_o.jpg)

## Configuración de red

Una de las ventajas del NUC es que trae un Hardware muy bien soportado por linux, así que tras el primer boot el equipo activa la tarjeta Ethernet y recibe una dirección IP vía DHCP.

 
 
livecd ~ # ip addr

1: lo: <LOOPBACK,UP,LOWER\_UP> mtu 65536 qdisc noqueue state UNKNOWN
 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
 inet 127.0.0.1/8 brd 127.255.255.255 scope host lo
 valid\_lft forever preferred\_lft forever
 inet6 ::1/128 scope host
 valid\_lft forever preferred\_lft forever

2: eno1: <BROADCAST,MULTICAST,UP,LOWER\_UP> mtu 1500 qdisc pfifo\_fast state UP qlen 1000
 link/ether c0:3f:d5:65:2e:75 brd ff:ff:ff:ff:ff:ff
 inet 192.168.1.245/24 brd 192.168.1.255 scope global eno1
 valid\_lft forever preferred\_lft forever
 inet6 fe80::c23f:d5ff:fe65:2e75/64 scope link
 valid\_lft forever preferred\_lft forever
 inet6 fe80::413:19a5:6c9:81a5/64 scope link
 valid\_lft forever preferred\_lft forever
 

 

## Conectar vía SSH

Te recomiendo que dejes de trabajar en la consola y pases a un puesto de trabajo remoto vía SSH, así que le asigno una contraseña a root, habilito la conexión vía ssh como root y método password y arranco el daemon:

 
 
livecd ~ # passwd

livecd ~ # nano /etc/ssh/sshd\_config
PermitRootLogin=yes
PasswordAuthentication=yes

livecd ~ # /etc/init.d/sshd start
 

A partir de aquí sigo desde un equipo remoto:

 
 
obelix:~ luis$ ssh -l root 192.168.1.245
 

## Apuntar y guardar información útil

Antes de continuar con la instalación siempre recomiendo guardar toda la información posible sobre el equipo que vamos a instalar, en particular todo lo relacionado con el hardware, que no será muy útil más adelante a la hora de configurar el kernel.

El ISO que hemos grabado en el USB contiene un kernel con cientos de módulos y hace una detección excelente del hardware de casi cualquier PC, así que ahora vamos a poder "ver" y apuntar qué ha detectado. Usa los comandos siguientes y guarda los resultados. Dejo aquí una copia como referencia sobre lo detectado durante el boot de este NUC D54250WYK

 
livecd ~ # lspci
00:00.0 Host bridge: Intel Corporation Haswell-ULT DRAM Controller (rev 09)
00:02.0 VGA compatible controller: Intel Corporation Haswell-ULT Integrated Graphics Controller (rev 09)
00:03.0 Audio device: Intel Corporation Haswell-ULT HD Audio Controller (rev 09)
00:14.0 USB controller: Intel Corporation 8 Series USB xHCI HC (rev 04)
00:16.0 Communication controller: Intel Corporation 8 Series HECI #0 (rev 04)
00:19.0 Ethernet controller: Intel Corporation Ethernet Connection I218-V (rev 04)
00:1b.0 Audio device: Intel Corporation 8 Series HD Audio Controller (rev 04)
00:1d.0 USB controller: Intel Corporation 8 Series USB EHCI #1 (rev 04)
00:1f.0 ISA bridge: Intel Corporation 8 Series LPC Controller (rev 04)
00:1f.2 SATA controller: Intel Corporation 8 Series SATA Controller 1 \[AHCI mode\] (rev 04)
00:1f.3 SMBus: Intel Corporation 8 Series SMBus Controller (rev 04)
 

 
# lsmod
Module Size Used by
cfg80211 171978 0
rfkill 13187 1 cfg80211
ac 3068 0
ipv6 238444 30
snd\_hda\_codec\_realtek 40224 1
snd\_hda\_codec\_generic 38488 1 snd\_hda\_codec\_realtek
snd\_hda\_codec\_hdmi 30236 1
snd\_hda\_intel 24266 0
snd\_hda\_codec 61877 4 snd\_hda\_codec\_realtek,snd\_hda\_codec\_hdmi,snd\_hda\_codec\_generic,snd\_hda\_intel
snd\_pcm 62263 3 snd\_hda\_codec\_hdmi,snd\_hda\_codec,snd\_hda\_intel
snd\_timer 15350 1 snd\_pcm
snd 48941 7 snd\_hda\_codec\_realtek,snd\_timer,snd\_hda\_codec\_hdmi,snd\_pcm,snd\_hda\_codec\_generic,snd\_hda\_codec,snd\_hda\_intel
e1000e 154159 0
x86\_pkg\_temp\_thermal 4357 0
soundcore 4226 1 snd
acpi\_cpufreq 5962 0
video 11193 0
backlight 4838 1 video
battery 7181 0
thermal 8076 0
processor 22817 5 acpi\_cpufreq
fan 2385 0
button 4205 0
thermal\_sys 17165 5 fan,video,thermal,processor,x86\_pkg\_temp\_thermal
xts 2607 0
gf128mul 5138 1 xts
aes\_x86\_64 7191 0
sha256\_generic 9500 0
iscsi\_tcp 7636 0
libiscsi\_tcp 10370 1 iscsi\_tcp
libiscsi 30708 2 libiscsi\_tcp,iscsi\_tcp
tg3 128277 0
ptp 6508 2 tg3,e1000e
pps\_core 5608 1 ptp
libphy 18043 1 tg3
hwmon 2385 2 tg3,thermal\_sys
e1000 86289 0
fuse 62998 1
jfs 133768 0
btrfs 641079 0
zlib\_deflate 17419 1 btrfs
multipath 5144 0
linear 3127 0
raid0 6227 0
dm\_raid 14596 0
raid456 51153 1 dm\_raid
async\_raid6\_recov 1201 1 raid456
async\_memcpy 1302 1 raid456
async\_pq 3884 1 raid456
async\_xor 2873 2 async\_pq,raid456
async\_tx 1662 5 async\_pq,raid456,async\_xor,async\_memcpy,async\_raid6\_recov
raid1 23296 1 dm\_raid
raid10 33488 1 dm\_raid
xor 10000 2 btrfs,async\_xor
raid6\_pq 89350 3 async\_pq,btrfs,async\_raid6\_recov
dm\_snapshot 23429 0
dm\_bufio 12686 1 dm\_snapshot
dm\_crypt 14222 0
dm\_mirror 10932 0
dm\_region\_hash 6159 1 dm\_mirror
dm\_log 7250 2 dm\_region\_hash,dm\_mirror
dm\_mod 67163 6 dm\_raid,dm\_log,dm\_mirror,dm\_bufio,dm\_crypt,dm\_snapshot
hid\_sunplus 1360 0
hid\_sony 6928 0
hid\_samsung 2709 0
hid\_pl 1296 0
hid\_petalynx 1825 0
hid\_gyration 1979 0
sl811\_hcd 8895 0
xhci\_hcd 80744 0
ohci\_hcd 16288 0
uhci\_hcd 18657 0
usb\_storage 42798 1
mpt2sas 119510 0
raid\_class 3084 1 mpt2sas
aic94xx 62985 0
libsas 54619 1 aic94xx
qla2xxx 455222 0
megaraid\_sas 72008 0
megaraid\_mbox 23716 0
megaraid\_mm 6632 1 megaraid\_mbox
megaraid 34321 0
aacraid 67716 0
sx8 10964 0
DAC960 60830 0
hpsa 43381 0
cciss 44094 0
3w\_9xxx 28962 0
3w\_xxxx 20668 0
mptsas 43057 0
scsi\_transport\_sas 20875 4 mpt2sas,libsas,mptsas,aic94xx
mptfc 12125 0
scsi\_transport\_fc 38525 2 qla2xxx,mptfc
scsi\_tgt 8040 1 scsi\_transport\_fc
mptspi 13286 0
mptscsih 23511 3 mptfc,mptsas,mptspi
mptbase 74964 4 mptfc,mptsas,mptspi,mptscsih
atp870u 22025 0
dc395x 26266 0
qla1280 19535 0
dmx3191d 9065 0
sym53c8xx 60940 0
gdth 71277 0
advansys 43968 0
initio 14604 0
BusLogic 19207 0
arcmsr 23730 0
aic7xxx 103058 0
aic79xx 117713 0
scsi\_transport\_spi 18707 5 mptspi,sym53c8xx,aic79xx,aic7xxx,dmx3191d
sg 23662 0
pdc\_adma 5109 0
sata\_inic162x 6317 0
sata\_mv 22961 0
ata\_piix 23711 0
ahci 22491 0
libahci 18191 1 ahci
sata\_qstor 4892 0
sata\_vsc 3857 0
sata\_uli 2924 0
sata\_sis 3573 0
sata\_sx4 7736 0
sata\_nv 17866 0
sata\_via 7499 0
sata\_svw 4165 0
sata\_sil24 9903 0
sata\_sil 7079 0
sata\_promise 9519 0
pata\_sl82c105 3525 0
pata\_cs5530 4128 0
pata\_cs5520 3510 0
pata\_via 8180 0
pata\_jmicron 2315 0
pata\_marvell 2811 0
pata\_sis 10190 1 sata\_sis
pata\_netcell 2129 0
pata\_sc1200 2890 0
pata\_pdc202xx\_old 4310 0
pata\_triflex 3055 0
pata\_atiixp 4379 0
pata\_opti 2689 0
pata\_amd 10071 0
pata\_ali 8989 0
pata\_it8213 3346 0
pata\_pcmcia 9636 0
pcmcia 28811 1 pata\_pcmcia
pcmcia\_core 10511 1 pcmcia
pata\_ns87415 3148 0
pata\_ns87410 2688 0
pata\_serverworks 5028 0
pata\_artop 4782 0
pata\_it821x 8165 0
pata\_optidma 4361 0
pata\_hpt3x2n 5332 0
pata\_hpt3x3 2936 0
pata\_hpt37x 10824 0
pata\_hpt366 4952 0
pata\_cmd64x 6778 0
pata\_efar 3494 0
pata\_rz1000 2645 0
pata\_sil680 4489 0
pata\_radisys 2842 0
pata\_pdc2027x 6107 0
pata\_mpiix 2782 0
libata 139318 52 ahci,pata\_pdc202xx\_old,sata\_inic162x,pata\_efar,pata\_opti,sata\_sil,sata\_sis,sata\_sx4,sata\_svw,sata\_uli,sata\_via,sata\_vsc,pata\_marvell,sata\_promise,sata\_mv,sata\_nv,libahci,sata\_qstor,sata\_sil24,pata\_netcell,pata\_ali,pata\_amd,pata\_sis,pata\_via,pata\_sl82c105,pata\_triflex,pata\_ns87410,pata\_ns87415,libsas,pdc\_adma,pata\_artop,pata\_atiixp,pata\_mpiix,pata\_cmd64x,pata\_cs5520,pata\_cs5530,pata\_hpt3x2n,pata\_optidma,pata\_hpt366,pata\_hpt37x,pata\_hpt3x3,pata\_it8213,pata\_it821x,pata\_serverworks,pata\_pcmcia,pata\_sc1200,pata\_sil680,pata\_rz1000,ata\_piix,pata\_jmicron,pata\_radisys,pata\_pdc2027x
 

 
livecd ~ # dmesg
\[ 0.000000\] Linux version 3.14.14-gentoo (root@nightheron) (gcc version 4.7.3 (Gentoo 4.7.3-r1 p1.5, pie-0.5.5) ) #1 SMP Thu Oct 23 06:24:17 UTC 2014
\[ 0.000000\] Command line: initrd=/gentoo.efimg.mountPoint/gentoo.igz root=/dev/ram0 init=/linuxrc dokeymap looptype=squashfs loop=/image.squashfs cdroot vga=791 BOOT\_IMAGE=/gentoo.efimg.mountPoint/gentoo
\[ 0.000000\] e820: BIOS-provided physical RAM map:
\[ 0.000000\] BIOS-e820: \[mem 0x0000000000000000-0x000000000009d7ff\] usable
\[ 0.000000\] BIOS-e820: \[mem 0x000000000009d800-0x000000000009ffff\] reserved
\[ 0.000000\] BIOS-e820: \[mem 0x00000000000e0000-0x00000000000fffff\] reserved
\[ 0.000000\] BIOS-e820: \[mem 0x0000000000100000-0x00000000aa1a0fff\] usable
\[ 0.000000\] BIOS-e820: \[mem 0x00000000aa1a1000-0x00000000aa1a7fff\] ACPI NVS
\[ 0.000000\] BIOS-e820: \[mem 0x00000000aa1a8000-0x00000000bda74fff\] usable
\[ 0.000000\] BIOS-e820: \[mem 0x00000000bda75000-0x00000000bdb0cfff\] reserved
\[ 0.000000\] BIOS-e820: \[mem 0x00000000bdb0d000-0x00000000bdb26fff\] ACPI data
\[ 0.000000\] BIOS-e820: \[mem 0x00000000bdb27000-0x00000000bdc8ffff\] ACPI NVS
\[ 0.000000\] BIOS-e820: \[mem 0x00000000bdc90000-0x00000000bdffefff\] reserved
\[ 0.000000\] BIOS-e820: \[mem 0x00000000bdfff000-0x00000000bdffffff\] usable
\[ 0.000000\] BIOS-e820: \[mem 0x00000000bf000000-0x00000000df1fffff\] reserved
\[ 0.000000\] BIOS-e820: \[mem 0x00000000f8000000-0x00000000fbffffff\] reserved
\[ 0.000000\] BIOS-e820: \[mem 0x00000000fec00000-0x00000000fec00fff\] reserved
\[ 0.000000\] BIOS-e820: \[mem 0x00000000fed00000-0x00000000fed03fff\] reserved
\[ 0.000000\] BIOS-e820: \[mem 0x00000000fed1c000-0x00000000fed1ffff\] reserved
\[ 0.000000\] BIOS-e820: \[mem 0x00000000fee00000-0x00000000fee00fff\] reserved
\[ 0.000000\] BIOS-e820: \[mem 0x00000000ff000000-0x00000000ffffffff\] reserved
\[ 0.000000\] BIOS-e820: \[mem 0x0000000100000000-0x000000041fdfffff\] usable
\[ 0.000000\] NX (Execute Disable) protection: active
\[ 0.000000\] SMBIOS 2.8 present.
\[ 0.000000\] DMI: /D54250WYK, BIOS WYLPT10H.86A.0030.2014.0919.1139 09/19/2014
\[ 0.000000\] e820: update \[mem 0x00000000-0x00000fff\] usable ==> reserved
\[ 0.000000\] e820: remove \[mem 0x000a0000-0x000fffff\] usable
\[ 0.000000\] No AGP bridge found
\[ 0.000000\] e820: last\_pfn = 0x41fe00 max\_arch\_pfn = 0x400000000
\[ 0.000000\] MTRR default type: uncachable
\[ 0.000000\] MTRR fixed ranges enabled:
\[ 0.000000\] 00000-9FFFF write-back
\[ 0.000000\] A0000-BFFFF uncachable
\[ 0.000000\] C0000-CFFFF write-protect
\[ 0.000000\] D0000-E7FFF uncachable
\[ 0.000000\] E8000-FFFFF write-protect
\[ 0.000000\] MTRR variable ranges enabled:
\[ 0.000000\] 0 base 0000000000 mask 7C00000000 write-back
\[ 0.000000\] 1 base 0400000000 mask 7FE0000000 write-back
\[ 0.000000\] 2 base 00C0000000 mask 7FC0000000 uncachable
\[ 0.000000\] 3 base 00BF000000 mask 7FFF000000 uncachable
\[ 0.000000\] 4 base 041FE00000 mask 7FFFE00000 uncachable
\[ 0.000000\] 5 disabled
\[ 0.000000\] 6 disabled
\[ 0.000000\] 7 disabled
\[ 0.000000\] 8 disabled
\[ 0.000000\] 9 disabled
\[ 0.000000\] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
\[ 0.000000\] e820: update \[mem 0xbf000000-0xffffffff\] usable ==> reserved
\[ 0.000000\] e820: last\_pfn = 0xbe000 max\_arch\_pfn = 0x400000000
\[ 0.000000\] found SMP MP-table at \[mem 0x000fd770-0x000fd77f\] mapped at \[ffff8800000fd770\]
\[ 0.000000\] Base memory trampoline at \[ffff880000097000\] 97000 size 24576
\[ 0.000000\] Using GB pages for direct mapping
\[ 0.000000\] init\_memory\_mapping: \[mem 0x00000000-0x000fffff\]
\[ 0.000000\] \[mem 0x00000000-0x000fffff\] page 4k
\[ 0.000000\] BRK \[0x019e5000, 0x019e5fff\] PGTABLE
\[ 0.000000\] BRK \[0x019e6000, 0x019e6fff\] PGTABLE
\[ 0.000000\] BRK \[0x019e7000, 0x019e7fff\] PGTABLE
\[ 0.000000\] init\_memory\_mapping: \[mem 0x41fc00000-0x41fdfffff\]
\[ 0.000000\] \[mem 0x41fc00000-0x41fdfffff\] page 2M
\[ 0.000000\] BRK \[0x019e8000, 0x019e8fff\] PGTABLE
\[ 0.000000\] init\_memory\_mapping: \[mem 0x41c000000-0x41fbfffff\]
\[ 0.000000\] \[mem 0x41c000000-0x41fbfffff\] page 2M
\[ 0.000000\] init\_memory\_mapping: \[mem 0x400000000-0x41bffffff\]
\[ 0.000000\] \[mem 0x400000000-0x41bffffff\] page 2M
\[ 0.000000\] init\_memory\_mapping: \[mem 0x00100000-0xaa1a0fff\]
\[ 0.000000\] \[mem 0x00100000-0x001fffff\] page 4k
\[ 0.000000\] \[mem 0x00200000-0x3fffffff\] page 2M
\[ 0.000000\] \[mem 0x40000000-0x7fffffff\] page 1G
\[ 0.000000\] \[mem 0x80000000-0xa9ffffff\] page 2M
\[ 0.000000\] \[mem 0xaa000000-0xaa1a0fff\] page 4k
\[ 0.000000\] init\_memory\_mapping: \[mem 0xaa1a8000-0xbda74fff\]
\[ 0.000000\] \[mem 0xaa1a8000-0xaa1fffff\] page 4k
\[ 0.000000\] \[mem 0xaa200000-0xbd9fffff\] page 2M
\[ 0.000000\] \[mem 0xbda00000-0xbda74fff\] page 4k
\[ 0.000000\] BRK \[0x019e9000, 0x019e9fff\] PGTABLE
\[ 0.000000\] init\_memory\_mapping: \[mem 0xbdfff000-0xbdffffff\]
\[ 0.000000\] \[mem 0xbdfff000-0xbdffffff\] page 4k
\[ 0.000000\] BRK \[0x019ea000, 0x019eafff\] PGTABLE
\[ 0.000000\] init\_memory\_mapping: \[mem 0x100000000-0x3ffffffff\]
\[ 0.000000\] \[mem 0x100000000-0x3ffffffff\] page 1G
\[ 0.000000\] RAMDISK: \[mem 0x7fbf4000-0x7fffefff\]
\[ 0.000000\] ACPI: RSDP 00000000000f04a0 000024 (v02 INTEL)
\[ 0.000000\] ACPI: XSDT 00000000bdb12088 00008C (v01 INTEL D54250WY 0000001E AMI 00010013)
\[ 0.000000\] ACPI: FACP 00000000bdb219a8 00010C (v05 INTEL D54250WY 0000001E AMI 00010013)
\[ 0.000000\] ACPI: DSDT 00000000bdb121a0 00F803 (v02 INTEL D54250WY 0000001E INTL 20120711)
\[ 0.000000\] ACPI: FACS 00000000bdc8ff80 000040
\[ 0.000000\] ACPI: APIC 00000000bdb21ab8 000072 (v03 INTEL D54250WY 0000001E AMI 00010013)
\[ 0.000000\] ACPI: FPDT 00000000bdb21b30 000044 (v01 INTEL D54250WY 0000001E AMI 00010013)
\[ 0.000000\] ACPI: FIDT 00000000bdb21b78 00009C (v01 INTEL D54250WY 0000001E AMI 00010013)
\[ 0.000000\] ACPI: SSDT 00000000bdb21c18 000486 (v01 INTEL D54250WY 0000001E INTL 20120711)
\[ 0.000000\] ACPI: SSDT 00000000bdb220a0 0004F7 (v01 INTEL D54250WY 0000001E INTL 20120711)
\[ 0.000000\] ACPI: SSDT 00000000bdb22598 000AD8 (v01 INTEL D54250WY 0000001E INTL 20120711)
\[ 0.000000\] ACPI: MCFG 00000000bdb23070 00003C (v01 INTEL D54250WY 0000001E MSFT 00000097)
\[ 0.000000\] ACPI: HPET 00000000bdb230b0 000038 (v01 INTEL D54250WY 0000001E AMI. 00000005)
\[ 0.000000\] ACPI: SSDT 00000000bdb230e8 000315 (v01 INTEL D54250WY 0000001E INTL 20120711)
\[ 0.000000\] ACPI: SSDT 00000000bdb23400 0030DF (v01 INTEL D54250WY 0000001E INTL 20091112)
\[ 0.000000\] ACPI: DMAR 00000000bdb264e0 0001AC (v01 INTEL D54250WY 0000001E INTL 00000001)
\[ 0.000000\] ACPI: CSRT 00000000bdb26690 0000C4 (v01 INTEL D54250WY 0000001E INTL 20100528)
\[ 0.000000\] ACPI: Local APIC address 0xfee00000
\[ 0.000000\] \[ffffea0000000000-ffffea000e7fffff\] PMD -> \[ffff88040fc00000-ffff88041d5fffff\] on node 0
\[ 0.000000\] Zone ranges:
\[ 0.000000\] DMA \[mem 0x00001000-0x00ffffff\]
\[ 0.000000\] DMA32 \[mem 0x01000000-0xffffffff\]
\[ 0.000000\] Normal \[mem 0x100000000-0x41fdfffff\]
\[ 0.000000\] Movable zone start for each node
\[ 0.000000\] Early memory node ranges
\[ 0.000000\] node 0: \[mem 0x00001000-0x0009cfff\]
\[ 0.000000\] node 0: \[mem 0x00100000-0xaa1a0fff\]
\[ 0.000000\] node 0: \[mem 0xaa1a8000-0xbda74fff\]
\[ 0.000000\] node 0: \[mem 0xbdfff000-0xbdffffff\]
\[ 0.000000\] node 0: \[mem 0x100000000-0x41fdfffff\]
\[ 0.000000\] On node 0 totalpages: 4053003
\[ 0.000000\] DMA zone: 56 pages used for memmap
\[ 0.000000\] DMA zone: 21 pages reserved
\[ 0.000000\] DMA zone: 3996 pages, LIFO batch:0
\[ 0.000000\] DMA32 zone: 10565 pages used for memmap
\[ 0.000000\] DMA32 zone: 772719 pages, LIFO batch:31
\[ 0.000000\] Normal zone: 44793 pages used for memmap
\[ 0.000000\] Normal zone: 3276288 pages, LIFO batch:31
\[ 0.000000\] ACPI: PM-Timer IO Port: 0x1808
\[ 0.000000\] ACPI: Local APIC address 0xfee00000
\[ 0.000000\] ACPI: LAPIC (acpi\_id\[0x01\] lapic\_id\[0x00\] enabled)
\[ 0.000000\] ACPI: LAPIC (acpi\_id\[0x02\] lapic\_id\[0x02\] enabled)
\[ 0.000000\] ACPI: LAPIC (acpi\_id\[0x03\] lapic\_id\[0x01\] enabled)
\[ 0.000000\] ACPI: LAPIC (acpi\_id\[0x04\] lapic\_id\[0x03\] enabled)
\[ 0.000000\] ACPI: LAPIC\_NMI (acpi\_id\[0xff\] high edge lint\[0x1\])
\[ 0.000000\] ACPI: IOAPIC (id\[0x08\] address\[0xfec00000\] gsi\_base\[0\])
\[ 0.000000\] IOAPIC\[0\]: apic\_id 8, version 32, address 0xfec00000, GSI 0-39
\[ 0.000000\] ACPI: INT\_SRC\_OVR (bus 0 bus\_irq 0 global\_irq 2 dfl dfl)
\[ 0.000000\] ACPI: INT\_SRC\_OVR (bus 0 bus\_irq 9 global\_irq 9 high level)
\[ 0.000000\] ACPI: IRQ0 used by override.
\[ 0.000000\] ACPI: IRQ2 used by override.
\[ 0.000000\] ACPI: IRQ9 used by override.
\[ 0.000000\] Using ACPI (MADT) for SMP configuration information
\[ 0.000000\] ACPI: HPET id: 0x8086a701 base: 0xfed00000
\[ 0.000000\] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
\[ 0.000000\] nr\_irqs\_gsi: 56
\[ 0.000000\] e820: \[mem 0xdf200000-0xf7ffffff\] available for PCI devices
\[ 0.000000\] Booting paravirtualized kernel on bare hardware
\[ 0.000000\] setup\_percpu: NR\_CPUS:64 nr\_cpumask\_bits:64 nr\_cpu\_ids:4 nr\_node\_ids:1
\[ 0.000000\] PERCPU: Embedded 27 pages/cpu @ffff88041fa00000 s78144 r8192 d24256 u524288
\[ 0.000000\] pcpu-alloc: s78144 r8192 d24256 u524288 alloc=1\*2097152
\[ 0.000000\] pcpu-alloc: \[0\] 0 1 2 3
\[ 0.000000\] Built 1 zonelists in Zone order, mobility grouping on. Total pages: 3997568
\[ 0.000000\] Kernel command line: initrd=/gentoo.efimg.mountPoint/gentoo.igz root=/dev/ram0 init=/linuxrc dokeymap looptype=squashfs loop=/image.squashfs cdroot vga=791 BOOT\_IMAGE=/gentoo.efimg.mountPoint/gentoo
\[ 0.000000\] PID hash table entries: 4096 (order: 3, 32768 bytes)
\[ 0.000000\] Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
\[ 0.000000\] Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
\[ 0.000000\] xsave: enabled xstate\_bv 0x7, cntxt size 0x340
\[ 0.000000\] Checking aperture...
\[ 0.000000\] No AGP bridge found
\[ 0.000000\] Memory: 15883176K/16212012K available (4560K kernel code, 412K rwdata, 1612K rodata, 868K init, 624K bss, 328836K reserved)
\[ 0.000000\] Hierarchical RCU implementation.
\[ 0.000000\] RCU restricting CPUs from NR\_CPUS=64 to nr\_cpu\_ids=4.
\[ 0.000000\] RCU: Adjusting geometry for rcu\_fanout\_leaf=16, nr\_cpu\_ids=4
\[ 0.000000\] NR\_IRQS:4352 nr\_irqs:984 16
\[ 0.000000\] Console: colour dummy device 80x25
\[ 0.000000\] console \[tty0\] enabled
\[ 0.000000\] hpet clockevent registered
\[ 0.000000\] tsc: Fast TSC calibration using PIT
\[ 0.000000\] tsc: Detected 1895.479 MHz processor
\[ 0.000002\] Calibrating delay loop (skipped), value calculated using timer frequency.. 3790.95 BogoMIPS (lpj=18954790)
\[ 0.000006\] pid\_max: default: 32768 minimum: 301
\[ 0.000013\] ACPI: Core revision 20131218
\[ 0.008082\] ACPI: All ACPI Tables successfully acquired
\[ 0.008257\] Mount-cache hash table entries: 32768 (order: 6, 262144 bytes)
\[ 0.008260\] Mountpoint-cache hash table entries: 32768 (order: 6, 262144 bytes)
\[ 0.008447\] CPU: Physical Processor ID: 0
\[ 0.008449\] CPU: Processor Core ID: 0
\[ 0.008453\] ENERGY\_PERF\_BIAS: Set to 'normal', was 'performance'
ENERGY\_PERF\_BIAS: View and update with x86\_energy\_perf\_policy(8)
\[ 0.009425\] mce: CPU supports 7 MCE banks
\[ 0.009437\] CPU0: Thermal monitoring enabled (TM1)
\[ 0.009448\] Last level iTLB entries: 4KB 1024, 2MB 1024, 4MB 1024
Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 1024, 1GB 4
tlb\_flushall\_shift: 6
\[ 0.009551\] Freeing SMP alternatives memory: 24K (ffffffff81942000 - ffffffff81948000)
\[ 0.010747\] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
\[ 0.110713\] smpboot: CPU0: Intel(R) Core(TM) i5-4250U CPU @ 1.30GHz (fam: 06, model: 45, stepping: 01)
\[ 0.110721\] TSC deadline timer enabled
\[ 0.110727\] Performance Events: PEBS fmt2+, 16-deep LBR, Haswell events, full-width counters, Intel PMU driver.
\[ 0.110735\] ... version: 3
\[ 0.110736\] ... bit width: 48
\[ 0.110737\] ... generic registers: 4
\[ 0.110738\] ... value mask: 0000ffffffffffff
\[ 0.110740\] ... max period: 0000ffffffffffff
\[ 0.110741\] ... fixed-purpose events: 3
\[ 0.110742\] ... event mask: 000000070000000f
\[ 0.110921\] x86: Booting SMP configuration:
\[ 0.110923\] .... node #0, CPUs: #1 #2 #3
\[ 0.153743\] x86: Booted up 1 node, 4 CPUs
\[ 0.153747\] smpboot: Total of 4 processors activated (15163.83 BogoMIPS)
\[ 0.157218\] devtmpfs: initialized
\[ 0.157518\] NET: Registered protocol family 16
\[ 0.157611\] cpuidle: using governor ladder
\[ 0.157613\] cpuidle: using governor menu
\[ 0.157678\] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
\[ 0.157680\] ACPI: bus type PCI registered
\[ 0.157727\] dca service started, version 1.12.1
\[ 0.157741\] PCI: MMCONFIG for domain 0000 \[bus 00-3f\] at \[mem 0xf8000000-0xfbffffff\] (base 0xf8000000)
\[ 0.157744\] PCI: MMCONFIG at \[mem 0xf8000000-0xfbffffff\] reserved in E820
\[ 0.157837\] PCI: Using configuration type 1 for base access
\[ 0.158671\] bio: create slab <bio-0> at 0
\[ 0.158758\] ACPI: Added \_OSI(Module Device)
\[ 0.158760\] ACPI: Added \_OSI(Processor Device)
\[ 0.158761\] ACPI: Added \_OSI(3.0 \_SCP Extensions)
\[ 0.158763\] ACPI: Added \_OSI(Processor Aggregator Device)
\[ 0.162646\] ACPI: Executed 1 blocks of module-level executable AML code
\[ 0.190752\] \[Firmware Bug\]: ACPI: BIOS \_OSI(Linux) query ignored
\[ 0.220862\] ACPI: SSDT 00000000bdb01c18 0003D3 (v01 PmRef Cpu0Cst 00003001 INTL 20120711)
\[ 0.221651\] ACPI: Dynamic OEM Table Load:
\[ 0.221655\] ACPI: SSDT (null) 0003D3 (v01 PmRef Cpu0Cst 00003001 INTL 20120711)
\[ 0.251054\] ACPI: SSDT 00000000bdb01618 0005AA (v01 PmRef ApIst 00003000 INTL 20120711)
\[ 0.251954\] ACPI: Dynamic OEM Table Load:
\[ 0.251958\] ACPI: SSDT (null) 0005AA (v01 PmRef ApIst 00003000 INTL 20120711)
\[ 0.280828\] ACPI: SSDT 00000000bdb00d98 000119 (v01 PmRef ApCst 00003000 INTL 20120711)
\[ 0.281609\] ACPI: Dynamic OEM Table Load:
\[ 0.281613\] ACPI: SSDT (null) 000119 (v01 PmRef ApCst 00003000 INTL 20120711)
\[ 0.311742\] ACPI: Interpreter enabled
\[ 0.311754\] ACPI: (supports S0 S5)
\[ 0.311756\] ACPI: Using IOAPIC for interrupt routing
\[ 0.311800\] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
\[ 0.312139\] ACPI: No dock devices found.
\[ 0.323170\] ACPI: Power Resource \[FN00\] (off)
\[ 0.323235\] ACPI: Power Resource \[FN01\] (off)
\[ 0.323299\] ACPI: Power Resource \[FN02\] (off)
\[ 0.323360\] ACPI: Power Resource \[FN03\] (off)
\[ 0.323421\] ACPI: Power Resource \[FN04\] (off)
\[ 0.324096\] ACPI: PCI Root Bridge \[PCI0\] (domain 0000 \[bus 00-3e\])
\[ 0.324102\] acpi PNP0A08:00: \_OSC: OS supports \[ExtendedConfig ASPM ClockPM Segments MSI\]
\[ 0.324293\] acpi PNP0A08:00: \_OSC: platform does not support \[PCIeHotplug PME\]
\[ 0.324405\] acpi PNP0A08:00: \_OSC: OS now controls \[AER PCIeCapability\]
\[ 0.324738\] PCI host bridge to bus 0000:00
\[ 0.324741\] pci\_bus 0000:00: root bus resource \[bus 00-3e\]
\[ 0.324744\] pci\_bus 0000:00: root bus resource \[io 0x0000-0x0cf7\]
\[ 0.324746\] pci\_bus 0000:00: root bus resource \[io 0x0d00-0xffff\]
\[ 0.324748\] pci\_bus 0000:00: root bus resource \[mem 0x000a0000-0x000bffff\]
\[ 0.324750\] pci\_bus 0000:00: root bus resource \[mem 0x000d0000-0x000d3fff\]
\[ 0.324752\] pci\_bus 0000:00: root bus resource \[mem 0x000d4000-0x000d7fff\]
\[ 0.324755\] pci\_bus 0000:00: root bus resource \[mem 0x000d8000-0x000dbfff\]
\[ 0.324757\] pci\_bus 0000:00: root bus resource \[mem 0x000dc000-0x000dffff\]
\[ 0.324759\] pci\_bus 0000:00: root bus resource \[mem 0x000e0000-0x000e3fff\]
\[ 0.324761\] pci\_bus 0000:00: root bus resource \[mem 0x000e4000-0x000e7fff\]
\[ 0.324763\] pci\_bus 0000:00: root bus resource \[mem 0xdf200000-0xfeafffff\]
\[ 0.324772\] pci 0000:00:00.0: \[8086:0a04\] type 00 class 0x060000
\[ 0.324854\] pci 0000:00:02.0: \[8086:0a26\] type 00 class 0x030000
\[ 0.324864\] pci 0000:00:02.0: reg 0x10: \[mem 0xf7800000-0xf7bfffff 64bit\]
\[ 0.324870\] pci 0000:00:02.0: reg 0x18: \[mem 0xe0000000-0xefffffff 64bit pref\]
\[ 0.324875\] pci 0000:00:02.0: reg 0x20: \[io 0xf000-0xf03f\]
\[ 0.324946\] pci 0000:00:03.0: \[8086:0a0c\] type 00 class 0x040300
\[ 0.324953\] pci 0000:00:03.0: reg 0x10: \[mem 0xf7c34000-0xf7c37fff 64bit\]
\[ 0.325047\] pci 0000:00:14.0: \[8086:9c31\] type 00 class 0x0c0330
\[ 0.325063\] pci 0000:00:14.0: reg 0x10: \[mem 0xf7c20000-0xf7c2ffff 64bit\]
\[ 0.325114\] pci 0000:00:14.0: PME# supported from D3hot D3cold
\[ 0.325151\] pci 0000:00:14.0: System wakeup disabled by ACPI
\[ 0.325184\] pci 0000:00:16.0: \[8086:9c3a\] type 00 class 0x078000
\[ 0.325202\] pci 0000:00:16.0: reg 0x10: \[mem 0xf7c3e000-0xf7c3e01f 64bit\]
\[ 0.325264\] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
\[ 0.325335\] pci 0000:00:19.0: \[8086:1559\] type 00 class 0x020000
\[ 0.325349\] pci 0000:00:19.0: reg 0x10: \[mem 0xf7c00000-0xf7c1ffff\]
\[ 0.325356\] pci 0000:00:19.0: reg 0x14: \[mem 0xf7c3c000-0xf7c3cfff\]
\[ 0.325363\] pci 0000:00:19.0: reg 0x18: \[io 0xf080-0xf09f\]
\[ 0.325414\] pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
\[ 0.325451\] pci 0000:00:19.0: System wakeup disabled by ACPI
\[ 0.325485\] pci 0000:00:1b.0: \[8086:9c20\] type 00 class 0x040300
\[ 0.325496\] pci 0000:00:1b.0: reg 0x10: \[mem 0xf7c30000-0xf7c33fff 64bit\]
\[ 0.325555\] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
\[ 0.325593\] pci 0000:00:1b.0: System wakeup disabled by ACPI
\[ 0.325627\] pci 0000:00:1d.0: \[8086:9c26\] type 00 class 0x0c0320
\[ 0.325646\] pci 0000:00:1d.0: reg 0x10: \[mem 0xf7c3b000-0xf7c3b3ff\]
\[ 0.325727\] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
\[ 0.325779\] pci 0000:00:1d.0: System wakeup disabled by ACPI
\[ 0.325811\] pci 0000:00:1f.0: \[8086:9c43\] type 00 class 0x060100
\[ 0.325972\] pci 0000:00:1f.2: \[8086:9c03\] type 00 class 0x010601
\[ 0.325985\] pci 0000:00:1f.2: reg 0x10: \[io 0xf0d0-0xf0d7\]
\[ 0.325991\] pci 0000:00:1f.2: reg 0x14: \[io 0xf0c0-0xf0c3\]
\[ 0.325997\] pci 0000:00:1f.2: reg 0x18: \[io 0xf0b0-0xf0b7\]
\[ 0.326003\] pci 0000:00:1f.2: reg 0x1c: \[io 0xf0a0-0xf0a3\]
\[ 0.326009\] pci 0000:00:1f.2: reg 0x20: \[io 0xf060-0xf07f\]
\[ 0.326015\] pci 0000:00:1f.2: reg 0x24: \[mem 0xf7c3a000-0xf7c3a7ff\]
\[ 0.326046\] pci 0000:00:1f.2: PME# supported from D3hot
\[ 0.326104\] pci 0000:00:1f.3: \[8086:9c22\] type 00 class 0x0c0500
\[ 0.326116\] pci 0000:00:1f.3: reg 0x10: \[mem 0xf7c39000-0xf7c390ff 64bit\]
\[ 0.326133\] pci 0000:00:1f.3: reg 0x20: \[io 0xf040-0xf05f\]
\[ 0.326197\] pci\_bus 0000:00: on NUMA node 0
\[ 0.326198\] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupported)
\[ 0.326764\] ACPI: PCI Interrupt Link \[LNKA\] (IRQs 3 4 5 6 10 \*11 12 14 15)
\[ 0.326814\] ACPI: PCI Interrupt Link \[LNKB\] (IRQs 3 4 5 6 10 11 12 14 15) \*0, disabled.
\[ 0.326864\] ACPI: PCI Interrupt Link \[LNKC\] (IRQs 3 4 5 6 \*10 11 12 14 15)
\[ 0.326910\] ACPI: PCI Interrupt Link \[LNKD\] (IRQs 3 4 5 6 \*10 11 12 14 15)
\[ 0.326957\] ACPI: PCI Interrupt Link \[LNKE\] (IRQs 3 4 \*5 6 10 11 12 14 15)
\[ 0.327005\] ACPI: PCI Interrupt Link \[LNKF\] (IRQs 3 4 5 6 10 11 12 14 15) \*0, disabled.
\[ 0.327171\] ACPI: PCI Interrupt Link \[LNKG\] (IRQs \*3 4 5 6 10 11 12 14 15)
\[ 0.327214\] ACPI: PCI Interrupt Link \[LNKH\] (IRQs 3 4 5 6 10 \*11 12 14 15)
\[ 0.327355\] ACPI: Enabled 4 GPEs in block 00 to 7F
\[ 0.327419\] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
\[ 0.327423\] vgaarb: loaded
\[ 0.327424\] vgaarb: bridge control possible 0000:00:02.0
\[ 0.327492\] SCSI subsystem initialized
\[ 0.327494\] ACPI: bus type USB registered
\[ 0.327510\] usbcore: registered new interface driver usbfs
\[ 0.327520\] usbcore: registered new interface driver hub
\[ 0.327545\] usbcore: registered new device driver usb
\[ 0.327590\] PCI: Using ACPI for IRQ routing
\[ 0.328880\] PCI: pci\_cache\_line\_size set to 64 bytes
\[ 0.328911\] e820: reserve RAM buffer \[mem 0x0009d800-0x0009ffff\]
\[ 0.328913\] e820: reserve RAM buffer \[mem 0xaa1a1000-0xabffffff\]
\[ 0.328914\] e820: reserve RAM buffer \[mem 0xbda75000-0xbfffffff\]
\[ 0.328916\] e820: reserve RAM buffer \[mem 0xbe000000-0xbfffffff\]
\[ 0.328918\] e820: reserve RAM buffer \[mem 0x41fe00000-0x41fffffff\]
\[ 0.329120\] Switched to clocksource hpet
\[ 0.330749\] pnp: PnP ACPI init
\[ 0.330758\] ACPI: bus type PNP registered
\[ 0.330857\] system 00:00: \[mem 0xfed40000-0xfed44fff\] has been reserved
\[ 0.330863\] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
\[ 0.330879\] pnp 00:01: \[dma 4\]
\[ 0.330899\] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
\[ 0.330935\] pnp 00:02: Plug and Play ACPI device, IDs INT0800 (active)
\[ 0.331068\] pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
\[ 0.331238\] system 00:04: \[io 0x0680-0x069f\] has been reserved
\[ 0.331242\] system 00:04: \[io 0xffff\] has been reserved
\[ 0.331246\] system 00:04: \[io 0xffff\] has been reserved
\[ 0.331249\] system 00:04: \[io 0xffff\] has been reserved
\[ 0.331253\] system 00:04: \[io 0x1c00-0x1cfe\] has been reserved
\[ 0.331256\] system 00:04: \[io 0x1d00-0x1dfe\] has been reserved
\[ 0.331260\] system 00:04: \[io 0x1e00-0x1efe\] has been reserved
\[ 0.331263\] system 00:04: \[io 0x1f00-0x1ffe\] has been reserved
\[ 0.331267\] system 00:04: \[io 0x1800-0x18fe\] could not be reserved
\[ 0.331271\] system 00:04: \[io 0x164e-0x164f\] has been reserved
\[ 0.331275\] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
\[ 0.331311\] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
\[ 0.331365\] system 00:06: \[io 0x1854-0x1857\] has been reserved
\[ 0.331370\] system 00:06: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
\[ 0.331497\] system 00:07: \[io 0x0a00-0x0a1f\] has been reserved
\[ 0.331501\] system 00:07: \[io 0x0a00-0x0a0f\] has been reserved
\[ 0.331505\] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
\[ 0.331778\] pnp 00:08: Plug and Play ACPI device, IDs NTN0530 (active)
\[ 0.331833\] system 00:09: \[io 0x04d0-0x04d1\] has been reserved
\[ 0.331837\] system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
\[ 0.359184\] system 00:0a: \[mem 0xfe102000-0xfe102fff\] has been reserved
\[ 0.359190\] system 00:0a: \[mem 0xfe104000-0xfe104fff\] has been reserved
\[ 0.359194\] system 00:0a: \[mem 0xfe106000-0xfe106fff\] has been reserved
\[ 0.359199\] system 00:0a: \[mem 0xfe108000-0xfe108fff\] has been reserved
\[ 0.359203\] system 00:0a: \[mem 0xfe10a000-0xfe10afff\] has been reserved
\[ 0.359207\] system 00:0a: \[mem 0xfe10c000-0xfe10cfff\] has been reserved
\[ 0.359211\] system 00:0a: \[mem 0xfe10e000-0xfe10efff\] has been reserved
\[ 0.359216\] system 00:0a: \[mem 0xfe112000-0xfe112fff\] has been reserved
\[ 0.359220\] system 00:0a: \[mem 0xfe111000-0xfe111007\] has been reserved
\[ 0.359224\] system 00:0a: \[mem 0xfe111014-0xfe111fff\] has been reserved
\[ 0.359229\] system 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
\[ 0.359723\] system 00:0b: \[mem 0xfed1c000-0xfed1ffff\] has been reserved
\[ 0.359728\] system 00:0b: \[mem 0xfed10000-0xfed17fff\] has been reserved
\[ 0.359732\] system 00:0b: \[mem 0xfed18000-0xfed18fff\] has been reserved
\[ 0.359736\] system 00:0b: \[mem 0xfed19000-0xfed19fff\] has been reserved
\[ 0.359741\] system 00:0b: \[mem 0xf8000000-0xfbffffff\] has been reserved
\[ 0.359745\] system 00:0b: \[mem 0xfed20000-0xfed3ffff\] has been reserved
\[ 0.359749\] system 00:0b: \[mem 0xfed90000-0xfed93fff\] has been reserved
\[ 0.359753\] system 00:0b: \[mem 0xfed45000-0xfed8ffff\] has been reserved
\[ 0.359757\] system 00:0b: \[mem 0xff000000-0xffffffff\] has been reserved
\[ 0.359762\] system 00:0b: \[mem 0xfee00000-0xfeefffff\] could not be reserved
\[ 0.359766\] system 00:0b: \[mem 0xf7fdf000-0xf7fdffff\] has been reserved
\[ 0.359770\] system 00:0b: \[mem 0xf7fe0000-0xf7feffff\] has been reserved
\[ 0.359775\] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
\[ 0.360222\] pnp: PnP ACPI: found 12 devices
\[ 0.360224\] ACPI: bus type PNP unregistered
\[ 0.364813\] pci\_bus 0000:00: resource 4 \[io 0x0000-0x0cf7\]
\[ 0.364815\] pci\_bus 0000:00: resource 5 \[io 0x0d00-0xffff\]
\[ 0.364816\] pci\_bus 0000:00: resource 6 \[mem 0x000a0000-0x000bffff\]
\[ 0.364817\] pci\_bus 0000:00: resource 7 \[mem 0x000d0000-0x000d3fff\]
\[ 0.364818\] pci\_bus 0000:00: resource 8 \[mem 0x000d4000-0x000d7fff\]
\[ 0.364820\] pci\_bus 0000:00: resource 9 \[mem 0x000d8000-0x000dbfff\]
\[ 0.364821\] pci\_bus 0000:00: resource 10 \[mem 0x000dc000-0x000dffff\]
\[ 0.364822\] pci\_bus 0000:00: resource 11 \[mem 0x000e0000-0x000e3fff\]
\[ 0.364823\] pci\_bus 0000:00: resource 12 \[mem 0x000e4000-0x000e7fff\]
\[ 0.364825\] pci\_bus 0000:00: resource 13 \[mem 0xdf200000-0xfeafffff\]
\[ 0.364857\] NET: Registered protocol family 2
\[ 0.364972\] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
\[ 0.365089\] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
\[ 0.365195\] TCP: Hash tables configured (established 131072 bind 65536)
\[ 0.365214\] TCP: reno registered
\[ 0.365217\] UDP hash table entries: 8192 (order: 6, 262144 bytes)
\[ 0.365250\] UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes)
\[ 0.365323\] NET: Registered protocol family 1
\[ 0.365392\] RPC: Registered named UNIX socket transport module.
\[ 0.365394\] RPC: Registered udp transport module.
\[ 0.365395\] RPC: Registered tcp transport module.
\[ 0.365397\] RPC: Registered tcp NFSv4.1 backchannel transport module.
\[ 0.365404\] pci 0000:00:02.0: Boot video device
\[ 0.389225\] PCI: CLS 64 bytes, default 64
\[ 0.389277\] Trying to unpack rootfs image as initramfs...
\[ 0.868921\] Freeing initrd memory: 4140K (ffff88007fbf4000 - ffff88007ffff000)
\[ 0.868937\] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
\[ 0.868940\] software IO TLB \[mem 0xb9a75000-0xbda75000\] (64MB) mapped at \[ffff8800b9a75000-ffff8800bda74fff\]
\[ 0.869137\] RAPL PMU detected, hw unit 2^-14 Joules, API unit is 2^-32 Joules, 3 fixed counters 655360 ms ovfl timer
\[ 0.869270\] futex hash table entries: 1024 (order: 4, 65536 bytes)
\[ 0.869537\] VFS: Disk quotas dquot\_6.5.2
\[ 0.869553\] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
\[ 0.869653\] squashfs: version 4.0 (2009/01/31) Phillip Lougher
\[ 0.869732\] NFS: Registering the id\_resolver key type
\[ 0.869739\] Key type id\_resolver registered
\[ 0.869740\] Key type id\_legacy registered
\[ 0.869747\] NTFS driver 2.1.30 \[Flags: R/O\].
\[ 0.869773\] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
\[ 0.869901\] msgmni has been set to 31029
\[ 0.870016\] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
\[ 0.870018\] io scheduler noop registered
\[ 0.870020\] io scheduler deadline registered (default)
\[ 0.870092\] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
\[ 0.890776\] serial8250: ttyS0 at I/O 0x3f8 (irq = 4, base\_baud = 115200) is a 16550A
\[ 0.890933\] Linux agpgart interface v0.103
\[ 0.890963\] vesafb: cannot reserve video memory at 0xe0000000
\[ 0.890965\] vesafb: mode is 1024x768x16, linelength=2048, pages=84
\[ 0.890967\] vesafb: scrolling: redraw
\[ 0.890969\] vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
\[ 0.890980\] vesafb: framebuffer at 0xe0000000, mapped to 0xffffc90004100000, using 3072k, total 524224k
\[ 0.923712\] Console: switching to colour frame buffer device 128x48
\[ 0.956490\] fb0: VESA VGA frame buffer device
\[ 0.956688\] ioatdma: Intel(R) QuickData Technology Driver 4.00
\[ 0.956986\] xenfs: not registering filesystem on non-xen platform
\[ 0.958047\] brd: module loaded
\[ 0.958542\] loop: module loaded
\[ 0.958660\] Loading iSCSI transport class v2.0-870.
\[ 0.958936\] st: Version 20101219, fixed bufsize 32768, s/g segs 256
\[ 0.959277\] SCSI Media Changer driver v0.25
\[ 0.959468\] Atheros(R) L2 Ethernet Driver - version 2.2.3
\[ 0.959771\] Copyright (c) 2007 Atheros Corporation.
\[ 0.960060\] jme: JMicron JMC2XX ethernet driver version 1.0.8
\[ 0.960421\] ehci\_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
\[ 0.960793\] ehci-pci: EHCI PCI platform driver
\[ 0.961114\] ehci-pci 0000:00:1d.0: EHCI Host Controller
\[ 0.961370\] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 1
\[ 0.961773\] ehci-pci 0000:00:1d.0: debug port 2
\[ 0.965863\] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
\[ 0.965876\] ehci-pci 0000:00:1d.0: irq 23, io mem 0xf7c3b000
\[ 0.978909\] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
\[ 0.991713\] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
\[ 1.005766\] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
\[ 1.020673\] usb usb1: Product: EHCI Host Controller
\[ 1.035567\] usb usb1: Manufacturer: Linux 3.14.14-gentoo ehci\_hcd
\[ 1.050255\] usb usb1: SerialNumber: 0000:00:1d.0
\[ 1.063623\] hub 1-0:1.0: USB hub found
\[ 1.075308\] hub 1-0:1.0: 2 ports detected
\[ 1.089614\] i8042: PNP: No PS/2 controller found. Probing ports directly.
\[ 2.172527\] i8042: No controller found
\[ 2.178455\] tsc: Refined TSC clocksource calibration: 1895.613 MHz
\[ 2.196032\] Switched to clocksource tsc
\[ 2.196064\] mousedev: PS/2 mouse device common for all mice
\[ 2.196141\] rtc\_cmos 00:05: RTC can wake from S4
\[ 2.196253\] rtc\_cmos 00:05: rtc core: registered rtc\_cmos as rtc0
\[ 2.196280\] rtc\_cmos 00:05: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
\[ 2.196295\] hidraw: raw HID events driver (C) Jiri Kosina
\[ 2.196359\] usbcore: registered new interface driver usbhid
\[ 2.196360\] usbhid: USB HID core driver
\[ 2.281285\] TCP: cubic registered
\[ 2.294012\] NET: Registered protocol family 17
\[ 2.306221\] Key type dns\_resolver registered
\[ 2.320117\] rtc\_cmos 00:05: setting system clock to 2014-10-28 20:59:59 UTC (1414529999)
\[ 2.334637\] Freeing unused kernel memory: 868K (ffffffff81869000 - ffffffff81942000)
\[ 2.347726\] Write protecting the kernel read-only data: 8192k
\[ 2.363766\] Freeing unused kernel memory: 1572K (ffff880001477000 - ffff880001600000)
\[ 2.379316\] Freeing unused kernel memory: 436K (ffff880001793000 - ffff880001800000)
\[ 2.418399\] usb 1-1: new high-speed USB device number 2 using ehci-pci
\[ 2.568613\] usb 1-1: New USB device found, idVendor=8087, idProduct=8000
\[ 2.568617\] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
\[ 2.568928\] hub 1-1:1.0: USB hub found
\[ 2.568985\] hub 1-1:1.0: 8 ports detected
\[ 2.617174\] libata version 3.00 loaded.
\[ 2.771215\] ahci 0000:00:1f.2: version 3.0
\[ 2.771343\] ahci 0000:00:1f.2: irq 56 for MSI/MSI-X
\[ 2.788326\] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 2 ports 6 Gbps 0x8 impl SATA mode
\[ 2.788332\] ahci 0000:00:1f.2: flags: 64bit ncq pm led clo only pio slum part deso sadm sds apst
\[ 2.789571\] scsi0 : ahci
\[ 2.789789\] scsi1 : ahci
\[ 2.789970\] scsi2 : ahci
\[ 2.790159\] scsi3 : ahci
\[ 2.790316\] ata1: DUMMY
\[ 2.790318\] ata2: DUMMY
\[ 2.790319\] ata3: DUMMY
\[ 2.790323\] ata4: SATA max UDMA/133 abar m2048@0xf7c3a000 port 0xf7c3a280 irq 56
\[ 3.138133\] ata4: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
\[ 3.138486\] ata4.00: supports DRM functions and may not be fully accessible
\[ 3.141293\] ata4.00: disabling queued TRIM support
\[ 3.141296\] ata4.00: ATA-9: Crucial\_CT240M500SSD3, MU05, max UDMA/133
\[ 3.141298\] ata4.00: 468862128 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
\[ 3.144773\] ata4.00: supports DRM functions and may not be fully accessible
\[ 3.147576\] ata4.00: disabling queued TRIM support
\[ 3.150752\] ata4.00: configured for UDMA/133
\[ 3.150873\] scsi 3:0:0:0: Direct-Access ATA Crucial\_CT240M50 MU05 PQ: 0 ANSI: 5
\[ 3.151240\] sd 3:0:0:0: \[sda\] 468862128 512-byte logical blocks: (240 GB/223 GiB)
\[ 3.151244\] sd 3:0:0:0: \[sda\] 4096-byte physical blocks
\[ 3.151342\] sd 3:0:0:0: \[sda\] Write Protect is off
\[ 3.151347\] sd 3:0:0:0: \[sda\] Mode Sense: 00 3a 00 00
\[ 3.151374\] sd 3:0:0:0: \[sda\] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
\[ 3.151735\] sda: unknown partition table
\[ 3.152007\] sd 3:0:0:0: \[sda\] Attached SCSI disk
\[ 3.183374\] sd 3:0:0:0: Attached scsi generic sg0 type 0
\[ 3.221870\] scsi: <fdomain> Detection failed (no card)
\[ 3.250307\] GDT-HA: Storage RAID Controller Driver. Version: 3.05
\[ 3.342911\] Fusion MPT base driver 3.04.20
\[ 3.342912\] Copyright (c) 1999-2008 LSI Corporation
\[ 3.362180\] Fusion MPT SPI Host driver 3.04.20
\[ 3.364614\] Fusion MPT FC Host driver 3.04.20
\[ 3.367040\] Fusion MPT SAS Host driver 3.04.20
\[ 3.368521\] 3ware Storage Controller device driver for Linux v1.26.02.003.
\[ 3.369962\] 3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
\[ 3.374809\] HP CISS Driver (v 3.6.26)
\[ 3.381040\] Adaptec aacraid driver 1.2-0\[30200\]-ms
\[ 3.383913\] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
\[ 3.384197\] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
\[ 3.387133\] megasas: 06.700.06.00-rc1 Sat. Aug. 31 17:00:00 PDT 2013
\[ 3.389815\] qla2xxx \[0000:00:00.0\]-0005: : QLogic Fibre Channel HBA Driver: 8.06.00.12-k.
\[ 3.410083\] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
\[ 3.412111\] mpt2sas version 16.100.00.00 loaded
\[ 3.445722\] usbcore: registered new interface driver usb-storage
\[ 3.447235\] uhci\_hcd: USB Universal Host Controller Interface driver
\[ 3.448893\] ohci\_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
\[ 3.450698\] xhci\_hcd 0000:00:14.0: xHCI Host Controller
\[ 3.450704\] xhci\_hcd 0000:00:14.0: new USB bus registered, assigned bus number 2
\[ 3.450780\] xhci\_hcd 0000:00:14.0: cache line size of 64 is not supported
\[ 3.450797\] xhci\_hcd 0000:00:14.0: irq 57 for MSI/MSI-X
\[ 3.450871\] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
\[ 3.450873\] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
\[ 3.450874\] usb usb2: Product: xHCI Host Controller
\[ 3.450875\] usb usb2: Manufacturer: Linux 3.14.14-gentoo xhci\_hcd
\[ 3.450876\] usb usb2: SerialNumber: 0000:00:14.0
\[ 3.451042\] hub 2-0:1.0: USB hub found
\[ 3.451057\] hub 2-0:1.0: 9 ports detected
\[ 3.453101\] xhci\_hcd 0000:00:14.0: xHCI Host Controller
\[ 3.453105\] xhci\_hcd 0000:00:14.0: new USB bus registered, assigned bus number 3
\[ 3.453157\] usb usb3: New USB device found, idVendor=1d6b, idProduct=0003
\[ 3.453159\] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
\[ 3.453160\] usb usb3: Product: xHCI Host Controller
\[ 3.453161\] usb usb3: Manufacturer: Linux 3.14.14-gentoo xhci\_hcd
\[ 3.453162\] usb usb3: SerialNumber: 0000:00:14.0
\[ 3.453314\] hub 3-0:1.0: USB hub found
\[ 3.453328\] hub 3-0:1.0: 4 ports detected
\[ 3.592470\] device-mapper: uevent: version 1.0.3
\[ 3.592547\] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised: dm-devel@redhat.com
\[ 3.767948\] usb 2-1: new high-speed USB device number 2 using xhci\_hcd
\[ 3.787875\] raid6: sse2x1 7314 MB/s
\[ 3.939275\] usb 2-1: New USB device found, idVendor=090c, idProduct=1000
\[ 3.939277\] usb 2-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
\[ 3.939278\] usb 2-1: Product: Flash Disk
\[ 3.939279\] usb 2-1: Manufacturer: USB
\[ 3.939280\] usb 2-1: SerialNumber: FBH1111180841062
\[ 3.939385\] usb 2-1: ep 0x81 - rounding interval to 128 microframes, ep desc says 255 microframes
\[ 3.939390\] usb 2-1: ep 0x2 - rounding interval to 128 microframes, ep desc says 255 microframes
\[ 3.939634\] usb-storage 2-1:1.0: USB Mass Storage device detected
\[ 3.939680\] scsi4 : usb-storage 2-1:1.0
\[ 3.957812\] raid6: sse2x2 9208 MB/s
\[ 4.057855\] usb 2-2: new full-speed USB device number 3 using xhci\_hcd
\[ 4.127748\] raid6: sse2x4 10778 MB/s
\[ 4.200290\] usb 2-2: New USB device found, idVendor=046d, idProduct=c51a
\[ 4.200292\] usb 2-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
\[ 4.200293\] usb 2-2: Product: USB Receiver
\[ 4.200294\] usb 2-2: Manufacturer: Logitech
\[ 4.202697\] input: Logitech USB Receiver as /devices/pci0000:00/0000:00:14.0/usb2/2-2/2-2:1.0/0003:046D:C51A.0001/input/input0
\[ 4.202879\] hid-generic 0003:046D:C51A.0001: input,hidraw0: USB HID v1.11 Mouse \[Logitech USB Receiver\] on usb-0000:00:14.0-2/input0
\[ 4.205166\] input: Logitech USB Receiver as /devices/pci0000:00/0000:00:14.0/usb2/2-2/2-2:1.1/0003:046D:C51A.0002/input/input1
\[ 4.205378\] hid-generic 0003:046D:C51A.0002: input,hiddev0,hidraw1: USB HID v1.11 Device \[Logitech USB Receiver\] on usb-0000:00:14.0-2/input1
\[ 4.297686\] raid6: avx2x1 14409 MB/s
\[ 4.378011\] usb 2-3: new low-speed USB device number 4 using xhci\_hcd
\[ 4.467624\] raid6: avx2x2 16480 MB/s
\[ 4.536462\] usb 2-3: New USB device found, idVendor=04d9, idProduct=1503
\[ 4.536464\] usb 2-3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
\[ 4.536465\] usb 2-3: Product: USB Keyboard
\[ 4.536466\] usb 2-3: Manufacturer:
\[ 4.536560\] usb 2-3: ep 0x81 - rounding interval to 64 microframes, ep desc says 80 microframes
\[ 4.536565\] usb 2-3: ep 0x82 - rounding interval to 64 microframes, ep desc says 80 microframes
\[ 4.546636\] input: USB Keyboard as /devices/pci0000:00/0000:00:14.0/usb2/2-3/2-3:1.0/0003:04D9:1503.0003/input/input2
\[ 4.546772\] hid-generic 0003:04D9:1503.0003: input,hidraw2: USB HID v1.10 Keyboard \[ USB Keyboard\] on usb-0000:00:14.0-3/input0
\[ 4.563581\] input: USB Keyboard as /devices/pci0000:00/0000:00:14.0/usb2/2-3/2-3:1.1/0003:04D9:1503.0004/input/input3
\[ 4.563700\] hid-generic 0003:04D9:1503.0004: input,hidraw3: USB HID v1.10 Device \[ USB Keyboard\] on usb-0000:00:14.0-3/input1
\[ 4.637564\] raid6: avx2x4 19210 MB/s
\[ 4.637566\] raid6: using algorithm avx2x4 (19210 MB/s)
\[ 4.637567\] raid6: using avx2x2 recovery algorithm
\[ 4.637768\] xor: automatically using best checksumming function:
\[ 4.737525\] avx : 23173.200 MB/sec
\[ 4.737867\] md: raid10 personality registered for level 10
\[ 4.738123\] md: raid1 personality registered for level 1
\[ 4.738272\] async\_tx: api initialized (async)
\[ 4.739172\] md: raid6 personality registered for level 6
\[ 4.739174\] md: raid5 personality registered for level 5
\[ 4.739175\] md: raid4 personality registered for level 4
\[ 4.739393\] device-mapper: raid: Loading target version 1.5.2
\[ 4.742402\] md: raid0 personality registered for level 0
\[ 4.756576\] md: linear personality registered for level -1
\[ 4.758490\] md: multipath personality registered for level -4
\[ 4.793765\] bio: create slab <bio-1> at 1
\[ 4.793890\] Btrfs loaded
\[ 4.799575\] JFS: nTxBlock = 8192, nTxLock = 65536
\[ 4.813147\] fuse init (API version 7.22)
\[ 4.830996\] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
\[ 4.830998\] e1000: Copyright (c) 1999-2006 Intel Corporation.
\[ 4.833586\] pps\_core: LinuxPPS API ver. 1 registered
\[ 4.833588\] pps\_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
\[ 4.833879\] PTP clock support registered
\[ 4.862625\] iscsi: registered transport (tcp)
\[ 5.096573\] scsi 4:0:0:0: Direct-Access USB Flash Disk 1100 PQ: 0 ANSI: 4
\[ 5.097114\] sd 4:0:0:0: Attached scsi generic sg1 type 0
\[ 5.097184\] sd 4:0:0:0: \[sdb\] 7831552 512-byte logical blocks: (4.00 GB/3.73 GiB)
\[ 5.097616\] sd 4:0:0:0: \[sdb\] Write Protect is off
\[ 5.097618\] sd 4:0:0:0: \[sdb\] Mode Sense: 43 00 00 00
\[ 5.098027\] sd 4:0:0:0: \[sdb\] No Caching mode page found
\[ 5.098028\] sd 4:0:0:0: \[sdb\] Assuming drive cache: write through
\[ 5.099442\] sd 4:0:0:0: \[sdb\] No Caching mode page found
\[ 5.099443\] sd 4:0:0:0: \[sdb\] Assuming drive cache: write through
\[ 5.100077\] sdb: sdb1
\[ 5.101338\] sd 4:0:0:0: \[sdb\] No Caching mode page found
\[ 5.101339\] sd 4:0:0:0: \[sdb\] Assuming drive cache: write through
\[ 5.101341\] sd 4:0:0:0: \[sdb\] Attached SCSI removable disk
\[ 6.206533\] UDF-fs: warning (device sda): udf\_fill\_super: No partition found (2)
\[ 7.927550\] random: nonblocking pool is initialized
\[ 11.059982\] systemd-udevd\[10726\]: starting version 216
\[ 11.139701\] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input4
\[ 11.139828\] ACPI: Power Button \[PWRB\]
\[ 11.139886\] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input5
\[ 11.139913\] ACPI: Power Button \[PWRF\]
\[ 11.145023\] ACPI: Fan \[FAN0\] (off)
\[ 11.145063\] ACPI: Fan \[FAN1\] (off)
\[ 11.145101\] ACPI: Fan \[FAN2\] (off)
\[ 11.145132\] ACPI: Fan \[FAN3\] (off)
\[ 11.145807\] Monitor-Mwait will be used to enter C-1 state
\[ 11.145811\] Monitor-Mwait will be used to enter C-2 state
\[ 11.145816\] ACPI: acpi\_idle registered with cpuidle
\[ 11.145834\] ACPI: Fan \[FAN4\] (off)
\[ 11.146319\] thermal LNXTHERM:00: registered as thermal\_zone0
\[ 11.146320\] ACPI: Thermal Zone \[TZ00\] (28 C)
\[ 11.146549\] thermal LNXTHERM:01: registered as thermal\_zone1
\[ 11.146550\] ACPI: Thermal Zone \[TZ01\] (30 C)
\[ 11.199923\] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
\[ 11.199924\] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
\[ 11.200080\] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
\[ 11.200096\] e1000e 0000:00:19.0: irq 58 for MSI/MSI-X
\[ 11.572001\] e1000e 0000:00:19.0 eth0: registered PHC clock
\[ 11.572004\] e1000e 0000:00:19.0 eth0: (PCI Express:2.5GT/s:Width x1) c0:3f:d5:65:2e:75
\[ 11.572005\] e1000e 0000:00:19.0 eth0: Intel(R) PRO/1000 Network Connection
\[ 11.572040\] e1000e 0000:00:19.0 eth0: MAC: 11, PHY: 12, PBA No: FFFFFF-0FF
\[ 11.572180\] hda-intel Haswell must build in CONFIG\_SND\_HDA\_I915
\[ 11.572346\] snd\_hda\_intel 0000:00:03.0: irq 59 for MSI/MSI-X
\[ 11.572444\] snd\_hda\_intel 0000:00:1b.0: irq 60 for MSI/MSI-X
\[ 11.595168\] systemd-udevd\[10740\]: renamed network interface eth0 to eno1
\[ 12.508198\] warning: process \`hwsetup' used the deprecated sysctl system call with 1.23.
\[ 18.150291\] NET: Registered protocol family 10
\[ 18.535719\] cfg80211: Calling CRDA to update world regulatory domain
\[ 18.557698\] cfg80211: World regulatory domain updated:
\[ 18.557700\] cfg80211: DFS Master region: unset
\[ 18.557701\] cfg80211: (start\_freq - end\_freq @ bandwidth), (max\_antenna\_gain, max\_eirp)
\[ 18.557703\] cfg80211: (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
\[ 18.557704\] cfg80211: (2457000 KHz - 2482000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
\[ 18.557705\] cfg80211: (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
\[ 18.557706\] cfg80211: (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
\[ 18.557706\] cfg80211: (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
\[ 18.762640\] e1000e 0000:00:19.0: irq 58 for MSI/MSI-X
\[ 18.872481\] e1000e 0000:00:19.0: irq 58 for MSI/MSI-X
\[ 18.872581\] IPv6: ADDRCONF(NETDEV\_UP): eno1: link is not ready
\[ 22.432688\] e1000e: eno1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
\[ 22.432721\] IPv6: ADDRCONF(NETDEV\_CHANGE): eno1: link becomes ready
 

Volver al paso anterior: [crear usb para instalar](https://www.luispa.com/?p=9) o ir al siguiente: [particionar el disco](https://www.luispa.com/?p=774)
