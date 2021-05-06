---
title: "Virtualización: Hypervisor KVM"
date: "2015-05-23"
categories: apuntes gentoo virtualizacion
tags: hypervisor kvm vm
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/Main_Page"
    caption="Hypervisor basado en KVM"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/HyperKVM-1024x1002.png"
    caption="HyperKVM"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=29) he decidido aprender KVM y darle una oportunidad por varios motivos: garantía de soporte del Hardware casero, menor consumo de memoria (ESXi consume aprox 2GB"
    caption="funcionando con éxito el Hypervisor ESXi"
    width="600px"
    %}

 

# Instalación del Host (Gentoo)

Aquí tienes los pasos necesarios para preparar un Host KVM con Gentoo Linux.

{% include showImagen.html
    src="/assets/img/original/?p=9"
    caption="Crea un USB"
    width="600px"
    %}

Una de las ventajas del NUC NUC5i5RYK es que trae un Hardware muy bien soportado por linux, así que tras el primer boot el equipo activa la tarjeta Ethernet y recibe una dirección IP vía DHCP.

  
livecd ~ # ip addr
1: lo: mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 brd 127.255.255.255 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s25: mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether b8:ae:ed:73:93:99 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.24/24 brd 192.168.1.255 scope global enp0s25
       valid_lft forever preferred_lft forever
    inet6 fe80::baae:edff:fe73:9399/64 scope link
       valid_lft forever preferred_lft forever
    inet6 fe80::9de:ff3f:c88c:ce87/64 scope link
       valid_lft forever preferred_lft forever 

Te recomiendo que dejes de trabajar en la consola y pases a un puesto de trabajo remoto vía SSH, asigno una contraseña a root, verifico que tiene "PermitRootLogin yes" y arranco el daemon:

 
livecd ~ # passwd
:
livecd ~ # nano /etc/ssh/sshd_config
PermitRootLogin yes
:
livecd ~ # /etc/init.d/sshd start 

A partir de aquí sigo desde un equipo remoto:

 
obelix:~ luis$ ssh -l root 192.168.1.24

Siempre recomiendo guardar toda la información posible sobre el equipo que vamos a instalar, en particular todo lo relacionado con el hardware, que será muy útil a la hora de configurar el kernel.

El ISO que hemos grabado en el USB contiene un kernel con cientos de módulos y hace una detección excelente del hardware de casi cualquier PC, así que ahora vamos a poder "ver" y apuntar qué ha detectado. Usa los comandos siguientes y guarda los resultados. Dejo aquí una copia como referencia sobre lo detectado durante el boot de este Intel NUC5i5RYK

 
livecd ~ # lspci
00:00.0 Host bridge: Intel Corporation Broadwell-U Host Bridge -OPI (rev 09)
00:02.0 VGA compatible controller: Intel Corporation Broadwell-U Integrated Graphics (rev 09)
00:03.0 Audio device: Intel Corporation Broadwell-U Audio Controller (rev 09)
00:14.0 USB controller: Intel Corporation Wildcat Point-LP USB xHCI Controller (rev 03)
00:16.0 Communication controller: Intel Corporation Wildcat Point-LP MEI Controller #1 (rev 03)
00:19.0 Ethernet controller: Intel Corporation Ethernet Connection (3) I218-V (rev 03)
00:1b.0 Audio device: Intel Corporation Wildcat Point-LP High Definition Audio Controller (rev 03)
00:1c.0 PCI bridge: Intel Corporation Wildcat Point-LP PCI Express Root Port #1 (rev e3)
00:1c.4 PCI bridge: Intel Corporation Wildcat Point-LP PCI Express Root Port #5 (rev e3)
00:1d.0 USB controller: Intel Corporation Wildcat Point-LP USB EHCI Controller (rev 03)
00:1f.0 ISA bridge: Intel Corporation Wildcat Point-LP LPC Controller (rev 03)
00:1f.3 SMBus: Intel Corporation Wildcat Point-LP SMBus Controller (rev 03)
02:00.0 SATA controller: Kingston Technologies Device 0010 (rev 10)

 
livecd ~ # lsmod
Module                  Size  Used by
cfg80211              171978  0
rfkill                 13187  1 cfg80211
ac                      3068  0
ipv6                  238444  30
snd_hda_codec_realtek    40224  1
snd_hda_codec_generic    38488  1 snd_hda_codec_realtek
snd_hda_codec_hdmi     30236  1
snd_hda_intel          24266  0
snd_hda_codec          61877  4 snd_hda_codec_realtek,snd_hda_codec_hdmi,snd_hda_codec_generic,snd_hda_intel
snd_pcm                62263  3 snd_hda_codec_hdmi,snd_hda_codec,snd_hda_intel
snd_timer              15350  1 snd_pcm
e1000e                154159  0
x86_pkg_temp_thermal     4357  0
snd                    48941  7 snd_hda_codec_realtek,snd_timer,snd_hda_codec_hdmi,snd_pcm,snd_hda_codec_generic,snd_hda_codec,snd_hda_intel
soundcore               4226  1 snd
acpi_cpufreq            5962  0
video                  11193  0
backlight               4838  1 video
battery                 7181  0
processor              22817  5 acpi_cpufreq
thermal                 8076  0
fan                     2385  0
acpi_pad                5527  0
button                  4205  0
thermal_sys            17165  5 fan,video,thermal,processor,x86_pkg_temp_thermal
xts                     2607  0
gf128mul                5138  1 xts
aes_x86_64              7191  0
sha256_generic          9500  0
iscsi_tcp               7636  0
libiscsi_tcp           10370  1 iscsi_tcp
libiscsi               30708  2 libiscsi_tcp,iscsi_tcp
tg3                   128277  0
ptp                     6508  2 tg3,e1000e
pps_core                5608  1 ptp
libphy                 18043  1 tg3
hwmon                   2385  2 tg3,thermal_sys
e1000                  86289  0
fuse                   62998  1
jfs                   133768  0
btrfs                 641079  0
zlib_deflate           17419  1 btrfs
multipath               5144  0
linear                  3127  0
raid0                   6227  0
dm_raid                14596  0
raid456                51153  1 dm_raid
async_raid6_recov       1201  1 raid456
async_memcpy            1302  1 raid456
async_pq                3884  1 raid456
async_xor               2873  2 async_pq,raid456
async_tx                1662  5 async_pq,raid456,async_xor,async_memcpy,async_raid6_recov
raid1                  23296  1 dm_raid
raid10                 33488  1 dm_raid
xor                    10000  2 btrfs,async_xor
raid6_pq               89350  3 async_pq,btrfs,async_raid6_recov
dm_snapshot            23429  0
dm_bufio               12686  1 dm_snapshot
dm_crypt               14222  0
dm_mirror              10932  0
dm_region_hash          6159  1 dm_mirror
dm_log                  7250  2 dm_region_hash,dm_mirror
dm_mod                 67163  6 dm_raid,dm_log,dm_mirror,dm_bufio,dm_crypt,dm_snapshot
hid_sunplus             1360  0
hid_sony                6928  0
hid_samsung             2709  0
hid_pl                  1296  0
hid_petalynx            1825  0
hid_gyration            1979  0
sl811_hcd               8895  0
xhci_hcd               80744  0
ohci_hcd               16288  0
uhci_hcd               18657  0
usb_storage            42798  1
mpt2sas               119510  0
raid_class              3084  1 mpt2sas
aic94xx                62985  0
libsas                 54619  1 aic94xx
qla2xxx               455222  0
megaraid_sas           72008  0
megaraid_mbox          23716  0
megaraid_mm             6632  1 megaraid_mbox
megaraid               34321  0
aacraid                67716  0
sx8                    10964  0
DAC960                 60830  0
hpsa                   43381  0
cciss                  44094  0
3w_9xxx                28962  0
3w_xxxx                20668  0
mptsas                 43057  0
scsi_transport_sas     20875  4 mpt2sas,libsas,mptsas,aic94xx
mptfc                  12125  0
scsi_transport_fc      38525  2 qla2xxx,mptfc
scsi_tgt                8040  1 scsi_transport_fc
mptspi                 13286  0
mptscsih               23511  3 mptfc,mptsas,mptspi
mptbase                74964  4 mptfc,mptsas,mptspi,mptscsih
atp870u                22025  0
dc395x                 26266  0
qla1280                19535  0
dmx3191d                9065  0
sym53c8xx              60940  0
gdth                   71277  0
advansys               43968  0
initio                 14604  0
BusLogic               19207  0
arcmsr                 23730  0
aic7xxx               103058  0
aic79xx               117713  0
scsi_transport_spi     18707  5 mptspi,sym53c8xx,aic79xx,aic7xxx,dmx3191d
sg                     23662  0
pdc_adma                5109  0
sata_inic162x           6317  0
sata_mv                22961  0
ata_piix               23711  0
ahci                   22491  0
libahci                18191  1 ahci
sata_qstor              4892  0
sata_vsc                3857  0
sata_uli                2924  0
sata_sis                3573  0
sata_sx4                7736  0
sata_nv                17866  0
sata_via                7499  0
sata_svw                4165  0
sata_sil24              9903  0
sata_sil                7079  0
sata_promise            9519  0
pata_sl82c105           3525  0
pata_cs5530             4128  0
pata_cs5520             3510  0
pata_via                8180  0
pata_jmicron            2315  0
pata_marvell            2811  0
pata_sis               10190  1 sata_sis
pata_netcell            2129  0
pata_sc1200             2890  0
pata_pdc202xx_old       4310  0
pata_triflex            3055  0
pata_atiixp             4379  0
pata_opti               2689  0
pata_amd               10071  0
pata_ali                8989  0
pata_it8213             3346  0
pata_pcmcia             9636  0
pcmcia                 28811  1 pata_pcmcia
pcmcia_core            10511  1 pcmcia
pata_ns87415            3148  0
pata_ns87410            2688  0
pata_serverworks        5028  0
pata_artop              4782  0
pata_it821x             8165  0
pata_optidma            4361  0
pata_hpt3x2n            5332  0
pata_hpt3x3             2936  0
pata_hpt37x            10824  0
pata_hpt366             4952  0
pata_cmd64x             6778  0
pata_efar               3494  0
pata_rz1000             2645  0
pata_sil680             4489  0
pata_radisys            2842  0
pata_pdc2027x           6107  0
pata_mpiix              2782  0
libata                139318  52 ahci,pata_pdc202xx_old,sata_inic162x,pata_efar,pata_opti,sata_sil,sata_sis,sata_sx4,sata_svw,sata_uli,sata_via,sata_vsc,pata_marvell,sata_promise,sata_mv,sata_nv,libahci,sata_qstor,sata_sil24,pata_netcell,pata_ali,pata_amd,pata_sis,pata_via,pata_sl82c105,pata_triflex,pata_ns87410,pata_ns87415,libsas,pdc_adma,pata_artop,pata_atiixp,pata_mpiix,pata_cmd64x,pata_cs5520,pata_cs5530,pata_hpt3x2n,pata_optidma,pata_hpt366,pata_hpt37x,pata_hpt3x3,pata_it8213,pata_it821x,pata_serverworks,pata_pcmcia,pata_sc1200,pata_sil680,pata_rz1000,ata_piix,pata_jmicron,pata_radisys,pata_pdc2027x

 
[    0.000000] Linux version 3.14.14-gentoo (root@nightheron) (gcc version 4.7.3 (Gentoo 4.7.3-r1 p1.5, pie-0.5.5) ) #1 SMP Thu Oct 23 06:24:17 UTC 2014
[    0.000000] Command line: root=/dev/ram0 init=/linuxrc dokeymap looptype=squashfs loop=/image.squashfs cdroot slowusb initrd=gentoo.igz vga=791 BOOT_IMAGE=gentoo
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009bfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009c000-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000d500bfff] usable
[    0.000000] BIOS-e820: [mem 0x00000000d500c000-0x00000000d54f2fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000d54f3000-0x00000000da322fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000da323000-0x00000000da381fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000da382000-0x00000000da3a5fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000da3a6000-0x00000000dacd5fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000dacd6000-0x00000000daffefff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000dafff000-0x00000000daffffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000db800000-0x00000000dfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed03fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000041effffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI:                  /NUC5i5RYB, BIOS RYBDWi35.86A.0247.2015.0415.1351 04/15/2015
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x41f000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0000000000 mask 7F80000000 write-back
[    0.000000]   1 base 0080000000 mask 7FC0000000 write-back
[    0.000000]   2 base 00C0000000 mask 7FF0000000 write-back
[    0.000000]   3 base 00D0000000 mask 7FF8000000 write-back
[    0.000000]   4 base 00D8000000 mask 7FFE000000 write-back
[    0.000000]   5 base 00DA000000 mask 7FFF000000 write-back
[    0.000000]   6 base 0100000000 mask 7F00000000 write-back
[    0.000000]   7 base 0200000000 mask 7E00000000 write-back
[    0.000000]   8 base 0400000000 mask 7FE0000000 write-back
[    0.000000]   9 base 041F000000 mask 7FFF000000 uncachable
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820: update [mem 0xdb000000-0xffffffff] usable ==> reserved
[    0.000000] e820: last_pfn = 0xdb000 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fd820-0x000fd82f] mapped at [ffff8800000fd820]
[    0.000000] Base memory trampoline at [ffff880000096000] 96000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x019e5000, 0x019e5fff] PGTABLE
[    0.000000] BRK [0x019e6000, 0x019e6fff] PGTABLE
[    0.000000] BRK [0x019e7000, 0x019e7fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x41ee00000-0x41effffff]
[    0.000000]  [mem 0x41ee00000-0x41effffff] page 2M
[    0.000000] BRK [0x019e8000, 0x019e8fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x41c000000-0x41edfffff]
[    0.000000]  [mem 0x41c000000-0x41edfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x400000000-0x41bffffff]
[    0.000000]  [mem 0x400000000-0x41bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0xd500bfff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0xbfffffff] page 1G
[    0.000000]  [mem 0xc0000000-0xd4ffffff] page 2M
[    0.000000]  [mem 0xd5000000-0xd500bfff] page 4k
[    0.000000] init_memory_mapping: [mem 0xd54f3000-0xda322fff]
[    0.000000]  [mem 0xd54f3000-0xd55fffff] page 4k
[    0.000000]  [mem 0xd5600000-0xda1fffff] page 2M
[    0.000000]  [mem 0xda200000-0xda322fff] page 4k
[    0.000000] BRK [0x019e9000, 0x019e9fff] PGTABLE
[    0.000000] BRK [0x019ea000, 0x019eafff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0xdafff000-0xdaffffff]
[    0.000000]  [mem 0xdafff000-0xdaffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0x3ffffffff]
[    0.000000]  [mem 0x100000000-0x3ffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x7fbf4000-0x7fffefff]
[    0.000000] ACPI: RSDP 00000000000f0580 000024 (v02 INTEL )
[    0.000000] ACPI: XSDT 00000000da389088 000094 (v01  INTEL NUC5i3RY 000000F7 AMI  00010013)
[    0.000000] ACPI: FACP 00000000da39d218 00010C (v05  INTEL NUC5i3RY 000000F7 AMI  00010013)
[    0.000000] ACPI: DSDT 00000000da3891b0 014063 (v02  INTEL NUC5i3RY 000000F7 INTL 20120913)
[    0.000000] ACPI: FACS 00000000dacd4f80 000040
[    0.000000] ACPI: APIC 00000000da39d328 000084 (v03  INTEL NUC5i3RY 000000F7 AMI  00010013)
[    0.000000] ACPI: FPDT 00000000da39d3b0 000044 (v01  INTEL NUC5i3RY 000000F7 AMI  00010013)
[    0.000000] ACPI: FIDT 00000000da39d3f8 00009C (v01  INTEL NUC5i3RY 000000F7 AMI  00010013)
[    0.000000] ACPI: MCFG 00000000da39d498 00003C (v01  INTEL NUC5i3RY 000000F7 MSFT 00000097)
[    0.000000] ACPI: HPET 00000000da39d4d8 000038 (v01  INTEL NUC5i3RY 000000F7 AMI. 00000005)
[    0.000000] ACPI: SSDT 00000000da39d510 000495 (v01  INTEL NUC5i3RY 000000F7 INTL 20120913)
[    0.000000] ACPI: UEFI 00000000da39d9a8 000042 (v01  INTEL NUC5i3RY 000000F7      00000000)
[    0.000000] ACPI: SSDT 00000000da39d9f0 000C7D (v02  INTEL NUC5i3RY 000000F7 INTL 20120913)
[    0.000000] ACPI: ASF! 00000000da39e670 0000A0 (v32  INTEL NUC5i3RY 000000F7 TFSM 000F4240)
[    0.000000] ACPI: SSDT 00000000da39e710 0004D6 (v02  INTEL NUC5i3RY 000000F7 INTL 20120913)
[    0.000000] ACPI: SSDT 00000000da39ebe8 000B74 (v02  INTEL NUC5i3RY 000000F7 INTL 20120913)
[    0.000000] ACPI: SSDT 00000000da39f760 005BEF (v02  INTEL NUC5i3RY 000000F7 INTL 20120913)
[    0.000000] ACPI: DMAR 00000000da3a5350 0000D4 (v01  INTEL NUC5i3RY 000000F7 INTL 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000]  [ffffea0000000000-ffffea000e7fffff] PMD -> [ffff88040e600000-ffff88041c7fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x41effffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009bfff]
[    0.000000]   node   0: [mem 0x00100000-0xd500bfff]
[    0.000000]   node   0: [mem 0xd54f3000-0xda322fff]
[    0.000000]   node   0: [mem 0xdafff000-0xdaffffff]
[    0.000000]   node   0: [mem 0x100000000-0x41effffff]
[    0.000000] On node 0 totalpages: 4165080
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3995 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 12146 pages used for memmap
[    0.000000]   DMA32 zone: 888381 pages, LIFO batch:31
[    0.000000]   Normal zone: 44744 pages used for memmap
[    0.000000]   Normal zone: 3272704 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x1808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] low edge lint[0xc0])
[    0.000000] ACPI: NMI not connected to LINT 1!
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x0])
[    0.000000] ACPI: NMI not connected to LINT 1!
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] dfl dfl lint[0x0])
[    0.000000] ACPI: NMI not connected to LINT 1!
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] dfl dfl lint[0x0])
[    0.000000] ACPI: NMI not connected to LINT 1!
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-39
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 56
[    0.000000] e820: [mem 0xe0000000-0xf7ffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88041ec00000 s78144 r8192 d24256 u524288
[    0.000000] pcpu-alloc: s78144 r8192 d24256 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4108113
[    0.000000] Kernel command line: root=/dev/ram0 init=/linuxrc dokeymap looptype=squashfs loop=/image.squashfs cdroot slowusb initrd=gentoo.igz vga=791 BOOT_IMAGE=gentoo
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
[    0.000000] Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 16323288K/16660320K available (4560K kernel code, 412K rwdata, 1612K rodata, 868K init, 624K bss, 337032K reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU restricting CPUs from NR_CPUS=64 to nr_cpu_ids=4.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
[    0.000000] NR_IRQS:4352 nr_irqs:984 16
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] tsc: Detected 1596.274 MHz processor
[    0.000002] Calibrating delay loop (skipped), value calculated using timer frequency.. 3192.54 BogoMIPS (lpj=15962740)
[    0.000005] pid_max: default: 32768 minimum: 301
[    0.000012] ACPI: Core revision 20131218
[    0.009775] ACPI: All ACPI Tables successfully acquired
[    0.010373] Mount-cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.010376] Mountpoint-cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.010554] CPU: Physical Processor ID: 0
[    0.010556] CPU: Processor Core ID: 0
[    0.010560] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
[    0.011533] mce: CPU supports 7 MCE banks
[    0.011545] CPU0: Thermal monitoring enabled (TM1)
[    0.011554] Last level iTLB entries: 4KB 64, 2MB 8, 4MB 8
Last level dTLB entries: 4KB 64, 2MB 0, 4MB 0, 1GB 4
tlb_flushall_shift: 6
[    0.011872] Freeing SMP alternatives memory: 24K (ffffffff81942000 - ffffffff81948000)
[    0.012985] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
[    0.112917] smpboot: CPU0: Intel(R) Core(TM) i5-5250U CPU @ 1.60GHz (fam: 06, model: 3d, stepping: 04)
[    0.112924] TSC deadline timer enabled
[    0.112929] Performance Events: PEBS fmt2+, generic architected perfmon, full-width counters, Intel PMU driver.
[    0.112935] ... version:                3
[    0.112936] ... bit width:              48
[    0.112937] ... generic registers:      4
[    0.112939] ... value mask:             0000ffffffffffff
[    0.112940] ... max period:             0000ffffffffffff
[    0.112941] ... fixed-purpose events:   3
[    0.112942] ... event mask:             000000070000000f
[    0.113103] x86: Booting SMP configuration:
[    0.113105] .... node  #0, CPUs:      #1 #2 #3
[    0.155877] x86: Booted up 1 node, 4 CPUs
[    0.155880] smpboot: Total of 4 processors activated (12770.19 BogoMIPS)
[    0.159211] devtmpfs: initialized
[    0.159493] NET: Registered protocol family 16
[    0.159584] cpuidle: using governor ladder
[    0.159585] cpuidle: using governor menu
[    0.159651] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    0.159653] ACPI: bus type PCI registered
[    0.159695] dca service started, version 1.12.1
[    0.159707] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.159710] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    0.159795] PCI: Using configuration type 1 for base access
[    0.160562] bio: create slab at 0
[    0.160641] ACPI: Added _OSI(Module Device)
[    0.160642] ACPI: Added _OSI(Processor Device)
[    0.160644] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.160645] ACPI: Added _OSI(Processor Aggregator Device)
[    0.223125] ACPI: Executed 18 blocks of module-level executable AML code
[    0.372963] ACPI: SSDT 00000000da342918 0003D3 (v02  PmRef  Cpu0Cst 00003001 INTL 20120913)
[    0.373747] ACPI: Dynamic OEM Table Load:
[    0.373750] ACPI: SSDT           (null) 0003D3 (v02  PmRef  Cpu0Cst 00003001 INTL 20120913)
[    0.403111] ACPI: SSDT 00000000da343618 0005AA (v02  PmRef    ApIst 00003000 INTL 20120913)
[    0.403984] ACPI: Dynamic OEM Table Load:
[    0.403987] ACPI: SSDT           (null) 0005AA (v02  PmRef    ApIst 00003000 INTL 20120913)
[    0.432919] ACPI: SSDT 00000000da344c18 000119 (v02  PmRef    ApCst 00003000 INTL 20120913)
[    0.433698] ACPI: Dynamic OEM Table Load:
[    0.433701] ACPI: SSDT           (null) 000119 (v02  PmRef    ApCst 00003000 INTL 20120913)
[    0.463974] ACPI: Interpreter enabled
[    0.463983] ACPI: (supports S0 S5)
[    0.463985] ACPI: Using IOAPIC for interrupt routing
[    0.464023] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.464324] ACPI: No dock devices found.
[    0.466211] ACPI: Power Resource [PG00] (on)
[    0.493123] ACPI: Power Resource [PG01] (on)
[    0.523114] ACPI: Power Resource [PG02] (on)
[    0.562108] ACPI: Power Resource [FN00] (off)
[    0.562167] ACPI: Power Resource [FN01] (off)
[    0.562223] ACPI: Power Resource [FN02] (off)
[    0.562279] ACPI: Power Resource [FN03] (off)
[    0.562335] ACPI: Power Resource [FN04] (off)
[    0.563192] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
[    0.563198] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    0.563290] \_SB_.PCI0:_OSC invalid UUID
[    0.563291] _OSC request data:1 1f 0
[    0.563294] acpi PNP0A08:00: _OSC failed (AE_ERROR); disabling ASPM
[    0.563726] PCI host bridge to bus 0000:00
[    0.563729] pci_bus 0000:00: root bus resource [bus 00-3e]
[    0.563731] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.563733] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.563735] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.563737] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xfeafffff]
[    0.563746] pci 0000:00:00.0: [8086:1604] type 00 class 0x060000
[    0.563817] pci 0000:00:02.0: [8086:1626] type 00 class 0x030000
[    0.563826] pci 0000:00:02.0: reg 0x10: [mem 0xf6000000-0xf6ffffff 64bit]
[    0.563832] pci 0000:00:02.0: reg 0x18: [mem 0xe0000000-0xefffffff 64bit pref]
[    0.563836] pci 0000:00:02.0: reg 0x20: [io  0xf000-0xf03f]
[    0.563902] pci 0000:00:03.0: [8086:160c] type 00 class 0x040300
[    0.563909] pci 0000:00:03.0: reg 0x10: [mem 0xf7134000-0xf7137fff 64bit]
[    0.563994] pci 0000:00:14.0: [8086:9cb1] type 00 class 0x0c0330
[    0.564010] pci 0000:00:14.0: reg 0x10: [mem 0xf7120000-0xf712ffff 64bit]
[    0.564059] pci 0000:00:14.0: PME# supported from D3hot D3cold
[    0.564100] pci 0000:00:14.0: System wakeup disabled by ACPI
[    0.564130] pci 0000:00:16.0: [8086:9cba] type 00 class 0x078000
[    0.564148] pci 0000:00:16.0: reg 0x10: [mem 0xf713c000-0xf713c01f 64bit]
[    0.564208] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    0.564274] pci 0000:00:19.0: [8086:15a3] type 00 class 0x020000
[    0.564288] pci 0000:00:19.0: reg 0x10: [mem 0xf7100000-0xf711ffff]
[    0.564294] pci 0000:00:19.0: reg 0x14: [mem 0xf713a000-0xf713afff]
[    0.564301] pci 0000:00:19.0: reg 0x18: [io  0xf060-0xf07f]
[    0.564350] pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
[    0.564390] pci 0000:00:19.0: System wakeup disabled by ACPI
[    0.564416] pci 0000:00:1b.0: [8086:9ca0] type 00 class 0x040300
[    0.564432] pci 0000:00:1b.0: reg 0x10: [mem 0xf7130000-0xf7133fff 64bit]
[    0.564481] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.564519] pci 0000:00:1b.0: System wakeup disabled by ACPI
[    0.564545] pci 0000:00:1c.0: [8086:9c90] type 01 class 0x060400
[    0.564606] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.564644] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    0.564671] pci 0000:00:1c.4: [8086:9c98] type 01 class 0x060400
[    0.564727] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    0.564764] pci 0000:00:1c.4: System wakeup disabled by ACPI
[    0.564796] pci 0000:00:1d.0: [8086:9ca6] type 00 class 0x0c0320
[    0.564814] pci 0000:00:1d.0: reg 0x10: [mem 0xf7139000-0xf71393ff]
[    0.564894] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.564938] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    0.564968] pci 0000:00:1f.0: [8086:9cc3] type 00 class 0x060100
[    0.565118] pci 0000:00:1f.3: [8086:9ca2] type 00 class 0x0c0500
[    0.565130] pci 0000:00:1f.3: reg 0x10: [mem 0xf7138000-0xf71380ff 64bit]
[    0.565146] pci 0000:00:1f.3: reg 0x20: [io  0xf040-0xf05f]
[    0.565242] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.565297] pci 0000:02:00.0: [2646:0010] type 00 class 0x010601
[    0.565350] pci 0000:02:00.0: reg 0x24: [mem 0xf7020000-0xf7020fff]
[    0.565359] pci 0000:02:00.0: reg 0x30: [mem 0xf7000000-0xf701ffff pref]
[    0.565404] pci 0000:02:00.0: supports D1
[    0.565405] pci 0000:02:00.0: PME# supported from D0 D1 D3hot
[    0.565424] pci 0000:02:00.0: System wakeup disabled by ACPI
[    0.582795] pci 0000:00:1c.4: PCI bridge to [bus 02]
[    0.582801] pci 0000:00:1c.4:   bridge window [mem 0xf7000000-0xf70fffff]
[    0.582818] pci_bus 0000:00: on NUMA node 0
[    0.583423] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14 15)
[    0.583484] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.583542] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 *11 12 14 15)
[    0.583600] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 12 14 15)
[    0.583656] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 *5 6 10 11 12 14 15)
[    0.583712] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.583769] ACPI: PCI Interrupt Link [LNKG] (IRQs *3 4 5 6 10 11 12 14 15)
[    0.583825] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 *4 5 6 10 11 12 14 15)
[    0.584046] ACPI: Enabled 4 GPEs in block 00 to 7F
[    0.584129] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.584134] vgaarb: loaded
[    0.584135] vgaarb: bridge control possible 0000:00:02.0
[    0.584233] SCSI subsystem initialized
[    0.584235] ACPI: bus type USB registered
[    0.584258] usbcore: registered new interface driver usbfs
[    0.584270] usbcore: registered new interface driver hub
[    0.584306] usbcore: registered new device driver usb
[    0.584367] PCI: Using ACPI for IRQ routing
[    0.585592] PCI: pci_cache_line_size set to 64 bytes
[    0.585617] e820: reserve RAM buffer [mem 0x0009c000-0x0009ffff]
[    0.585619] e820: reserve RAM buffer [mem 0xd500c000-0xd7ffffff]
[    0.585619] e820: reserve RAM buffer [mem 0xda323000-0xdbffffff]
[    0.585621] e820: reserve RAM buffer [mem 0xdb000000-0xdbffffff]
[    0.585622] e820: reserve RAM buffer [mem 0x41f000000-0x41fffffff]
[    0.585760] Switched to clocksource hpet
[    0.586646] pnp: PnP ACPI init
[    0.586650] ACPI: bus type PNP registered
[    0.586770] system 00:00: [io  0x0a00-0x0a0f] has been reserved
[    0.586773] system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.586850] pnp 00:01: [dma 4]
[    0.586863] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.586879] pnp 00:02: Plug and Play ACPI device, IDs INT0800 (active)
[    0.586954] pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.586996] system 00:04: [io  0x0680-0x069f] has been reserved
[    0.586998] system 00:04: [io  0xffff] has been reserved
[    0.587000] system 00:04: [io  0xffff] has been reserved
[    0.587002] system 00:04: [io  0xffff] has been reserved
[    0.587004] system 00:04: [io  0x1800-0x18fe] could not be reserved
[    0.587006] system 00:04: [io  0x164e-0x164f] has been reserved
[    0.587009] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.587044] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.587071] system 00:06: [io  0x1854-0x1857] has been reserved
[    0.587073] system 00:06: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
[    0.587208] system 00:07: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.587211] system 00:07: [mem 0xfed10000-0xfed17fff] has been reserved
[    0.587213] system 00:07: [mem 0xfed18000-0xfed18fff] has been reserved
[    0.587215] system 00:07: [mem 0xfed19000-0xfed19fff] has been reserved
[    0.587217] system 00:07: [mem 0xf8000000-0xfbffffff] has been reserved
[    0.587219] system 00:07: [mem 0xfed20000-0xfed3ffff] has been reserved
[    0.587221] system 00:07: [mem 0xfed90000-0xfed93fff] has been reserved
[    0.587224] system 00:07: [mem 0xfed45000-0xfed8ffff] has been reserved
[    0.587226] system 00:07: [mem 0xff000000-0xffffffff] has been reserved
[    0.587228] system 00:07: [mem 0xfee00000-0xfeefffff] could not be reserved
[    0.587230] system 00:07: [mem 0xf7fe0000-0xf7feffff] has been reserved
[    0.587232] system 00:07: [mem 0xf7ff0000-0xf7ffffff] has been reserved
[    0.587235] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.587639] system 00:08: [mem 0xfe104000-0xfe104fff] has been reserved
[    0.587641] system 00:08: [mem 0xfe106000-0xfe106fff] has been reserved
[    0.587643] system 00:08: [mem 0xfe10e000-0xfe10efff] has been reserved
[    0.587645] system 00:08: [mem 0xfe112000-0xfe112fff] has been reserved
[    0.587648] system 00:08: [mem 0xfe111000-0xfe111007] has been reserved
[    0.587650] system 00:08: [mem 0xfe111014-0xfe111fff] has been reserved
[    0.587652] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.587992] pnp: PnP ACPI: found 9 devices
[    0.587994] ACPI: bus type PNP unregistered
[    0.592522] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.592532] pci 0000:00:1c.4: PCI bridge to [bus 02]
[    0.592537] pci 0000:00:1c.4:   bridge window [mem 0xf7000000-0xf70fffff]
[    0.592544] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.592545] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.592546] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.592547] pci_bus 0000:00: resource 7 [mem 0xe0000000-0xfeafffff]
[    0.592549] pci_bus 0000:02: resource 1 [mem 0xf7000000-0xf70fffff]
[    0.592580] NET: Registered protocol family 2
[    0.592685] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.592799] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.592902] TCP: Hash tables configured (established 131072 bind 65536)
[    0.592921] TCP: reno registered
[    0.592925] UDP hash table entries: 8192 (order: 6, 262144 bytes)
[    0.592955] UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes)
[    0.593022] NET: Registered protocol family 1
[    0.593090] RPC: Registered named UNIX socket transport module.
[    0.593092] RPC: Registered udp transport module.
[    0.593093] RPC: Registered tcp transport module.
[    0.593095] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.593102] pci 0000:00:02.0: Boot video device
[    0.615846] PCI: CLS 64 bytes, default 64
[    0.615891] Trying to unpack rootfs image as initramfs...
[    1.049520] Freeing initrd memory: 4140K (ffff88007fbf4000 - ffff88007ffff000)
[    1.049524] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.049527] software IO TLB [mem 0xd6323000-0xda323000] (64MB) mapped at [ffff8800d6323000-ffff8800da322fff]
[    1.049828] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    1.050060] VFS: Disk quotas dquot_6.5.2
[    1.050075] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.050168] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    1.050243] NFS: Registering the id_resolver key type
[    1.050250] Key type id_resolver registered
[    1.050251] Key type id_legacy registered
[    1.050258] NTFS driver 2.1.30 [Flags: R/O].
[    1.050281] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
[    1.050399] msgmni has been set to 31889
[    1.050501] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    1.050503] io scheduler noop registered
[    1.050504] io scheduler deadline registered (default)
[    1.050790] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.051011] Linux agpgart interface v0.103
[    1.051040] vesafb: mode is 1024x768x16, linelength=2048, pages=41
[    1.051041] vesafb: scrolling: redraw
[    1.051043] vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
[    1.051053] vesafb: framebuffer at 0xe0000000, mapped to 0xffffc90004100000, using 3072k, total 65472k
[    1.084000] Console: switching to colour frame buffer device 128x48
[    1.114635] fb0: VESA VGA frame buffer device
[    1.114830] ioatdma: Intel(R) QuickData Technology Driver 4.00
[    1.115124] xenfs: not registering filesystem on non-xen platform
[    1.116168] brd: module loaded
[    1.116794] loop: module loaded
[    1.116947] Loading iSCSI transport class v2.0-870.
[    1.117269] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    1.117648] SCSI Media Changer driver v0.25
[    1.117864] Atheros(R) L2 Ethernet Driver - version 2.2.3
[    1.118150] Copyright (c) 2007 Atheros Corporation.
[    1.118377] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    1.118658] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.118975] ehci-pci: EHCI PCI platform driver
[    1.119261] ehci-pci 0000:00:1d.0: EHCI Host Controller
[    1.119504] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 1
[    1.119926] ehci-pci 0000:00:1d.0: debug port 2
[    1.124037] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[    1.124049] ehci-pci 0000:00:1d.0: irq 23, io mem 0xf7139000
[    1.135367] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    1.149087] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.160907] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.172037] usb usb1: Product: EHCI Host Controller
[    1.182844] usb usb1: Manufacturer: Linux 3.14.14-gentoo ehci_hcd
[    1.193917] usb usb1: SerialNumber: 0000:00:1d.0
[    1.204909] hub 1-0:1.0: USB hub found
[    1.217102] hub 1-0:1.0: 2 ports detected
[    1.227786] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    1.243047] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.255834] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.268021] mousedev: PS/2 mouse device common for all mice
[    1.278988] rtc_cmos 00:05: RTC can wake from S4
[    1.289358] rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
[    1.300007] rtc_cmos 00:05: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
[    1.310439] hidraw: raw HID events driver (C) Jiri Kosina
[    1.321038] usbcore: registered new interface driver usbhid
[    1.331425] usbhid: USB HID core driver
[    1.342068] TCP: cubic registered
[    1.352341] NET: Registered protocol family 17
[    1.362347] Key type dns_resolver registered
[    1.372739] rtc_cmos 00:05: setting system clock to 2015-05-20 19:14:45 UTC (1432149285)
[    1.385381] Freeing unused kernel memory: 868K (ffffffff81869000 - ffffffff81942000)
[    1.397618] Write protecting the kernel read-only data: 8192k
[    1.413204] Freeing unused kernel memory: 1572K (ffff880001477000 - ffff880001600000)
[    1.426137] Freeing unused kernel memory: 436K (ffff880001793000 - ffff880001800000)
[    1.555054] usb 1-1: new high-speed USB device number 2 using ehci-pci
[    1.623472] libata version 3.00 loaded.
[    1.715283] usb 1-1: New USB device found, idVendor=8087, idProduct=8001
[    1.715284] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    1.715467] hub 1-1:1.0: USB hub found
[    1.715530] hub 1-1:1.0: 8 ports detected
[    1.769485] ahci 0000:02:00.0: version 3.0
[    1.769578] ahci 0000:02:00.0: irq 56 for MSI/MSI-X
[    1.784940] ahci 0000:02:00.0: AHCI 0001.0301 32 slots 1 ports 6 Gbps 0x1 impl SATA mode
[    1.784946] ahci 0000:02:00.0: flags: 64bit ncq only pio
[    1.785264] scsi0 : ahci
[    1.785428] ata1: SATA max UDMA/133 abar m4096@0xf7020000 port 0xf7020100 irq 56
[    2.044701] tsc: Refined TSC clocksource calibration: 1596.304 MHz
[    2.044730] Switched to clocksource tsc
[    2.134657] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    2.135408] ata1.00: ATA-8: Kingston SHPM2280P2/240G, OC34L5TA, max UDMA/133
[    2.135412] ata1.00: 468862128 sectors, multi 0: LBA48 NCQ (depth 31/32)
[    2.136306] ata1.00: configured for UDMA/133
[    2.136404] scsi 0:0:0:0: Direct-Access     ATA      Kingston SHPM228 OC34 PQ: 0 ANSI: 5
[    2.136725] sd 0:0:0:0: [sda] 468862128 512-byte logical blocks: (240 GB/223 GiB)
[    2.136727] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    2.136793] sd 0:0:0:0: [sda] Write Protect is off
[    2.136797] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.136815] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.138255]  sda: sda1 sda2 sda3
[    2.138684] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.168813] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    2.203616] scsi: Detection failed (no card)
[    2.226284] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[    2.327479] Fusion MPT base driver 3.04.20
[    2.327480] Copyright (c) 1999-2008 LSI Corporation
[    2.343029] Fusion MPT SPI Host driver 3.04.20
[    2.345193] Fusion MPT FC Host driver 3.04.20
[    2.347277] Fusion MPT SAS Host driver 3.04.20
[    2.348623] 3ware Storage Controller device driver for Linux v1.26.02.003.
[    2.349983] 3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
[    2.354354] HP CISS Driver (v 3.6.26)
[    2.360798] Adaptec aacraid driver 1.2-0[30200]-ms
[    2.363423] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
[    2.363688] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
[    2.366527] megasas: 06.700.06.00-rc1 Sat. Aug. 31 17:00:00 PDT 2013
[    2.369195] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.06.00.12-k.
[    2.391052] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[    2.393329] mpt2sas version 16.100.00.00 loaded
[    2.428321] usbcore: registered new interface driver usb-storage
[    2.429723] uhci_hcd: USB Universal Host Controller Interface driver
[    2.431141] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    2.432733] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    2.432738] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 2
[    2.432805] xhci_hcd 0000:00:14.0: cache line size of 64 is not supported
[    2.432819] xhci_hcd 0000:00:14.0: irq 57 for MSI/MSI-X
[    2.432884] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    2.432886] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.432887] usb usb2: Product: xHCI Host Controller
[    2.432888] usb usb2: Manufacturer: Linux 3.14.14-gentoo xhci_hcd
[    2.432889] usb usb2: SerialNumber: 0000:00:14.0
[    2.433036] hub 2-0:1.0: USB hub found
[    2.433051] hub 2-0:1.0: 11 ports detected
[    2.435766] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    2.435769] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 3
[    2.435813] usb usb3: New USB device found, idVendor=1d6b, idProduct=0003
[    2.435815] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.435816] usb usb3: Product: xHCI Host Controller
[    2.435817] usb usb3: Manufacturer: Linux 3.14.14-gentoo xhci_hcd
[    2.435818] usb usb3: SerialNumber: 0000:00:14.0
[    2.435959] hub 3-0:1.0: USB hub found
[    2.435971] hub 3-0:1.0: 4 ports detected
[    2.569138] device-mapper: uevent: version 1.0.3
[    2.569228] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised: dm-devel@redhat.com
[    2.754208] usb 3-2: new SuperSpeed USB device number 2 using xhci_hcd
[    2.764124] raid6: sse2x1    8134 MB/s
[    2.774509] usb 3-2: New USB device found, idVendor=1058, idProduct=0810
[    2.774510] usb 3-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    2.774512] usb 3-2: Product: My Passport 0810
[    2.774513] usb 3-2: Manufacturer: Western Digital
[    2.774514] usb 3-2: SerialNumber: 575833314537335845483539
[    2.775170] usb-storage 3-2:1.0: USB Mass Storage device detected
[    2.775214] scsi1 : usb-storage 3-2:1.0
[    2.894040] usb 2-3: new low-speed USB device number 2 using xhci_hcd
[    2.933995] raid6: sse2x2    9741 MB/s
[    3.053286] usb 2-3: New USB device found, idVendor=04d9, idProduct=1503
[    3.053288] usb 2-3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    3.053289] usb 2-3: Product: USB Keyboard
[    3.053290] usb 2-3: Manufacturer:
[    3.053383] usb 2-3: ep 0x81 - rounding interval to 64 microframes, ep desc says 80 microframes
[    3.053387] usb 2-3: ep 0x82 - rounding interval to 64 microframes, ep desc says 80 microframes
[    3.063431] input:   USB Keyboard as /devices/pci0000:00/0000:00:14.0/usb2/2-3/2-3:1.0/0003:04D9:1503.0001/input/input3
[    3.063555] hid-generic 0003:04D9:1503.0001: input,hidraw0: USB HID v1.10 Keyboard [  USB Keyboard] on usb-0000:00:14.0-3/input0
[    3.080387] input:   USB Keyboard as /devices/pci0000:00/0000:00:14.0/usb2/2-3/2-3:1.1/0003:04D9:1503.0002/input/input4
[    3.080494] hid-generic 0003:04D9:1503.0002: input,hidraw1: USB HID v1.10 Device [  USB Keyboard] on usb-0000:00:14.0-3/input1
[    3.103868] raid6: sse2x4   11665 MB/s
[    3.253887] usb 2-4: new full-speed USB device number 3 using xhci_hcd
[    3.273742] raid6: avx2x1   15934 MB/s
[    3.396292] usb 2-4: New USB device found, idVendor=046d, idProduct=c51a
[    3.396293] usb 2-4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    3.396295] usb 2-4: Product: USB Receiver
[    3.396296] usb 2-4: Manufacturer: Logitech
[    3.398742] input: Logitech USB Receiver as /devices/pci0000:00/0000:00:14.0/usb2/2-4/2-4:1.0/0003:046D:C51A.0003/input/input5
[    3.398903] hid-generic 0003:046D:C51A.0003: input,hidraw2: USB HID v1.11 Mouse [Logitech USB Receiver] on usb-0000:00:14.0-4/input0
[    3.401097] input: Logitech USB Receiver as /devices/pci0000:00/0000:00:14.0/usb2/2-4/2-4:1.1/0003:046D:C51A.0004/input/input6
[    3.401319] hid-generic 0003:046D:C51A.0004: input,hiddev0,hidraw3: USB HID v1.11 Device [Logitech USB Receiver] on usb-0000:00:14.0-4/input1
[    3.443612] raid6: avx2x2   18137 MB/s
[    3.613486] raid6: avx2x4   20991 MB/s
[    3.613487] raid6: using algorithm avx2x4 (20991 MB/s)
[    3.613487] raid6: using avx2x2 recovery algorithm
[    3.613690] xor: automatically using best checksumming function:
[    3.713410]    avx       : 25057.200 MB/sec
[    3.713773] md: raid10 personality registered for level 10
[    3.714016] md: raid1 personality registered for level 1
[    3.714161] async_tx: api initialized (async)
[    3.714996] md: raid6 personality registered for level 6
[    3.714997] md: raid5 personality registered for level 5
[    3.714998] md: raid4 personality registered for level 4
[    3.715186] device-mapper: raid: Loading target version 1.5.2
[    3.717917] md: raid0 personality registered for level 0
[    3.731016] md: linear personality registered for level -1
[    3.732638] md: multipath personality registered for level -4
[    3.759935] bio: create slab at 1
[    3.760042] Btrfs loaded
[    3.765052] JFS: nTxBlock = 8192, nTxLock = 65536
[    3.773725] scsi 1:0:0:0: Direct-Access     WD       My Passport 0810 1042 PQ: 0 ANSI: 6
[    3.773840] scsi 1:0:0:1: Enclosure         WD       SES Device       1042 PQ: 0 ANSI: 6
[    3.774178] sd 1:0:0:0: Attached scsi generic sg1 type 0
[    3.774274] sd 1:0:0:0: [sdb] 1953458176 512-byte logical blocks: (1.00 TB/931 GiB)
[    3.774453] scsi 1:0:0:1: Attached scsi generic sg2 type 13
[    3.774498] sd 1:0:0:0: [sdb] Write Protect is off
[    3.774500] sd 1:0:0:0: [sdb] Mode Sense: 53 00 10 08
[    3.774735] sd 1:0:0:0: [sdb] No Caching mode page found
[    3.774736] sd 1:0:0:0: [sdb] Assuming drive cache: write through
[    3.775464] sd 1:0:0:0: [sdb] No Caching mode page found
[    3.775466] sd 1:0:0:0: [sdb] Assuming drive cache: write through
[    3.777598] fuse init (API version 7.22)
[    3.794586] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    3.794587] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    3.796915] pps_core: LinuxPPS API ver. 1 registered
[    3.796916] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti [    3.797136] PTP clock support registered
[    3.819325] iscsi: registered transport (tcp)
[    3.834154]  sdb: sdb1 sdb2
[    3.835123] sd 1:0:0:0: [sdb] No Caching mode page found
[    3.835124] sd 1:0:0:0: [sdb] Assuming drive cache: write through
[    3.835125] sd 1:0:0:0: [sdb] Attached SCSI disk
[    5.107472] UDF-fs: warning (device sda2): udf_fill_super: No partition found (2)
[    5.107907] XFS (sda2): Mounting Filesystem
[    5.121304] XFS (sda2): Ending clean mount
[    5.180003] UDF-fs: warning (device sda3): udf_fill_super: No partition found (2)
[    6.276114] random: nonblocking pool is initialized
[    9.450429] systemd-udevd[10821]: starting version 216
[    9.532639] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input7
[    9.532708] ACPI: Sleep Button [SLPB]
[    9.532746] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input8
[    9.532782] ACPI: Power Button [PWRB]
[    9.532836] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input9
[    9.532863] ACPI: Power Button [PWRF]
[    9.541895] ACPI: Fan [FAN0] (off)
[    9.542486] thermal LNXTHERM:00: registered as thermal_zone0
[    9.542488] ACPI: Thermal Zone [TZ00] (28 C)
[    9.542629] thermal LNXTHERM:01: registered as thermal_zone1
[    9.542630] ACPI: Thermal Zone [TZ01] (30 C)
[    9.542675] ACPI: Fan [FAN1] (off)
[    9.542710] Monitor-Mwait will be used to enter C-1 state
[    9.542714] ACPI: Fan [FAN2] (off)
[    9.542718] Monitor-Mwait will be used to enter C-2 state
[    9.542724] Monitor-Mwait will be used to enter C-3 state
[    9.542734] ACPI: acpi_idle registered with cpuidle
[    9.542749] ACPI: Fan [FAN3] (off)
[    9.542792] ACPI: Fan [FAN4] (off)
[    9.589942] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[    9.589943] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[    9.590126] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
[    9.590140] e1000e 0000:00:19.0: irq 58 for MSI/MSI-X
[   10.005183] e1000e 0000:00:19.0 eth0: registered PHC clock
[   10.005186] e1000e 0000:00:19.0 eth0: (PCI Express:2.5GT/s:Width x1) b8:ae:ed:73:93:99
[   10.005187] e1000e 0000:00:19.0 eth0: Intel(R) PRO/1000 Network Connection
[   10.005219] e1000e 0000:00:19.0 eth0: MAC: 11, PHY: 12, PBA No: FFFFFF-0FF
[   10.038745] systemd-udevd[10836]: renamed network interface eth0 to enp0s25
[   10.135528] hda-intel Haswell must build in CONFIG_SND_HDA_I915
[   10.135846] snd_hda_intel 0000:00:03.0: irq 59 for MSI/MSI-X
[   10.135917] snd_hda_intel 0000:00:1b.0: irq 60 for MSI/MSI-X
[   12.885658] warning: process \`hwsetup' used the deprecated sysctl system call with 1.23.
[   14.399442] NET: Registered protocol family 10
[   14.747889] cfg80211: Calling CRDA to update world regulatory domain
[   14.770394] cfg80211: World regulatory domain updated:
[   14.770396] cfg80211:  DFS Master region: unset
[   14.770397] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[   14.770400] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   14.770401] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   14.770403] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[   14.770404] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   14.770405] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   14.975110] e1000e 0000:00:19.0: irq 58 for MSI/MSI-X
[   15.084907] e1000e 0000:00:19.0: irq 58 for MSI/MSI-X
[   15.084992] IPv6: ADDRCONF(NETDEV_UP): enp0s25: link is not ready
[   18.683660] e1000e: enp0s25 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
[   18.683688] IPv6: ADDRCONF(NETDEV_CHANGE): enp0s25: link becomes ready 

  **Crear las particiones del disco**

Antes de crear las particiones hay que identificar el nombre del dispositivo del disco SSD (y no confundirlo con el USB de arranque). Hay un par de maneras de averiguarlo: con dmesg o con fdisk.

  
livecd ~ # dmesg | grep "SCSI"
[    0.584233] SCSI subsystem initialized
[    1.050501] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    1.116947] Loading iSCSI transport class v2.0-870.
[    1.117648] SCSI Media Changer driver v0.25
[    2.138684] sd 0:0:0:0: [sda] Attached SCSI disk
[    3.835125] sd 1:0:0:0: [sdb] Attached SCSI disk
:
 
livecd ~ # fdisk -l
Disk /dev/sda: 223.6 GiB, 240057409536 bytes, 468862128 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 3FCBE377-7EE5-40B2-AA18-56AAFF8DADF5

Device           Start          End   Size Type
/dev/sda1         2048       411647   200M EFI System
/dev/sda2       411648      1435647   500M Microsoft basic data
/dev/sda3      1435648    468860927 222.9G Linux LVM

Disk /dev/sdb: 931.5 GiB, 1000170586112 bytes, 1953458176 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xe4e671ce

Device    Boot     Start        End    Blocks  Id System
/dev/sdb1 *         2048    8390655   4194304   b W95 FAT32
/dev/sdb2        8390656 1953458175 972533760  83 Linux

**Parted**

Teniendo claro cual es el disco (/dev/sda) empiezo a preparar las particiones. Notar que voy a usar UEFI y GPT (en vez de MBR) en el disco SSD del equipo.

  
livecd ~ # parted -a optimal /dev/sda
:
GNU Parted 3.1
Using /dev/sda
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mklabel gpt
(parted) unit mib
(parted) mkpart primary 1 3
(parted) name 1 grub
(parted) set 1 bios_grub on
(parted) mkpart primary 3 131
(parted) name 2 boot
(parted) mkpart primary 131 643
(parted) name 3 swap
(parted) mkpart primary 643 -1
(parted) name 4 rootfs
(parted) print
Model: ATA Crucial_CT240M50 (scsi)
Disk /dev/sda: 228937MiB
Sector size (logical/physical): 512B/4096B
Partition Table: gpt
Disk Flags:
Number Start End Size File system Name Flags
 1 1.00MiB 3.00MiB 2.00MiB grub bios_grub
 2 3.00MiB 131MiB 128MiB boot
 3 131MiB 643MiB 512MiB swap
 4 643MiB 228936MiB 228293MiB rootfs

(parted) quit

A continuación creo los file systems

  
livecd ~ # mkfs.ext2 /dev/sda2
livecd ~ # mkfs.ext4 /dev/sda4
livecd ~ # mkswap /dev/sda3
livecd ~ # swapon /dev/sda3 

Aunque todavía no podemos usar la versión gráfica "gparted", una vez que terminé la instalación así es como se ve desde dicho programa:

{% include showImagen.html
    src="/assets/img/original/particionar.png"
    caption="particionar"
    width="600px"
    %}

**Montamos root y boot**

  
livecd ~ # mount /dev/sda4 /mnt/gentoo
livecd ~ # mkdir /mnt/gentoo/boot
livecd ~ # mount /dev/sda2 /mnt/gentoo/boot 

**Ajustar la hora**

 
livecd ~ # date 102822082014   <== MMDDHHMMAAAA 

**Descarga de Stage 3**

{% include showImagen.html
    src="/assets/img/original/Main_Page"
    caption="Wiki de Gentoo"
    width="600px"
    %}

  
livecd ~ # cd /mnt/gentoo
livecd gentoo # links http://distfiles.gentoo.org

Descargo el último "stage3", el último "portage":

  
../releases/amd64/autobuilds/current-stage3-amd64/ --> stage3-amd64-<FECHA>.tar.bz2
../snapshots --> portage-latest.tar.bz2
:
livecd gentoo # tar xjpf stage3-*.tar.bz2
livecd gentoo # cd /mnt/gentoo/usr
livecd usr # tar xjpf ../portage-*.tar.bz2 

**chroot al nuevo entorno**

A partir de ahora "/" (root) apuntará al disco SSD que hemos formateado y donde hemos descomprimido Stage 3 y Portage.

Antes de hacer el chroot debes copiar el /etc/resolv.conf para que la red siga funcionando (sobre todo la resolución de nombres :-))

  
livecd usr # cp /etc/resolv.conf /mnt/gentoo/etc
 
livecd usr # mount -t proc none /mnt/gentoo/proc
livecd usr # mount --rbind /sys /mnt/gentoo/sys
livecd usr # mount --rbind /dev /mnt/gentoo/dev
livecd usr # chroot /mnt/gentoo /bin/bash
livecd / # source /etc/profile
livecd / # export PS1="(chroot) $PS1"
(chroot) livecd / #

Modificamos el fichero make.conf

#
# Opciones de compilacion, by LuisPa. -l'n' n=+1 CPUs
CFLAGS="-O2 -march=native -pipe"
CXXFLAGS="${CFLAGS}"
MAKEOPTS="-j5 -l10"
EMERGE_DEFAULT_OPTS="--nospinner --keep-going --jobs=5 --load-average=10"

# CHOST
CHOST="x86_64-pc-linux-gnu"

# USE Flags
USE="-bindist -gnome -kde  aes avx avx2 fma3 mmx mmxext popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"

# Nuevo CPU Flags, usar el siguiente programa para poner el correcto:
#  $ emerge -1v app-portage/cpuinfo2cpuflags
#  $ cpuinfo2cpuflags-x86
#
CPU_FLAGS_X86="aes avx avx2 fma3 mmx mmxext popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"

# Ubicaciones de portage
PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"

# Lenguaje
LINGUAS="es en"

# Mirrors
GENTOO_MIRRORS="http://gentoo-euetib.upc.es/mirror/gentoo/"

# Teclado y graficos
INPUT_DEVICES="keyboard mouse evdev"
VIDEO_CARDS="vesa"

Establezco el mirror y el rsync server

  
(chroot) livecd / # emerge mirrorselect
(chroot) livecd / # mirrorselect -i -o >> /etc/portage/make.conf
(chroot) livecd / # mirrorselect -i -r -o >> /etc/portage/make.conf

**Leemos todas las "News"**

(chroot) livecd ~ # eselect news list
(chroot) livecd ~ # eselect news read ’n’

**Establecemos la Zona horaria**

(chroot) livecd ~ # cd /
(chroot) livecd / # cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime
(chroot) livecd / # echo "Europe/Madrid" > /etc/timezone

**Preparo el /etc/fstab**

/dev/sda2 /boot ext2 noauto,noatime 1 2
/dev/sda3 none swap sw 0 0
/dev/sda4 / ext4 noatime 0 1

**Instalo herramientas**

Instalo herramientas útiles a la hora de trabajar con Portage y con el sistema en general.

(chroot) livecd ~ # emerge -pv eix genlop pciutils
(chroot) livecd ~ # eix-update

**Instalo v86d**

El uvesafb se apoya en módulos del kernel y en el daemon sys-apps/v86d para cambiar las resoluciones del display

# emerge -v v86d
# eselect python set --python3 python3.3 

**Instalo DHCP Cliente**

Para el futuro arranque tras el primer boot, mejor instalar ahora el paquete cliente de DHCP

(chroot) livecd ~ # emerge -v dhcpcd

**Preparo portage**

Preparo los ficheros de portage

# Systemd
sys-apps/systemd-ui ~amd64

# iproute
dev-haskell/appa ~amd64
dev-haskell/iproute ~amd64
dev-haskell/byteorder ~amd64

# Kernel 4
=sys-kernel/gentoo-sources-4.0.4 ~amd64

# Virt Manager 1.2
=app-emulation/virt-manager-1.2.0 ~amd64

net-misc/iputils -caps -filecaps

**Compilo el Kernel**

(chroot) livecd / # emerge -v gentoo-sources

{% include showImagen.html
    src="/assets/img/original/2015-06-07-config-4.0.4-NUC5i5RYK_KVM.txt"
    caption=".config para Kernel 4.0.4 para NUC5i5RYK"
    width="600px"
    %}

(chroot) livecd ~ # cd /usr/src/linux
(chroot) livecd linux # wget https://raw.githubusercontent.com/LuisPalacios/Linux-Kernel-configs/master/configs/2015-05-22-config-4.0.4-NUC5i5RYK_KVM.txt -O .config 
(chroot) livecd linux #
(chroot) livecd linux # make && make modules_install
(chroot) livecd linux # cp arch/x86_64/boot/bzImage /boot/kernel-4.0.4-gentoo
(chroot) livecd linux # cp System.map /boot/System.map-4.0.4-gentoo

 

### Instalación de "systemd"

Selecciono el perfil adecuado.

(chroot) livecd / # eselect profile list
:
[10]  default/linux/amd64/13.0/systemd 
:
(chroot) livecd / # eselect profile set 10 

**Recompilo con el nuevo Profile systemd**

Una vez que se selecciona un Profile distinto lo que ocurre es que cambias los valores USE de por defecto del sistema y esto significa que tenemos que "recompilarlo" por completo, así que lo siguiente que vamos a hacer es un emerge que actualice "world":

# emerge -avDN @world

**Hostname**

Con systemd se deja de usar /etc/conf.d/hostname, así que voy a editar a mano directamente los dos ficheros que emplea systemd. - Llamé a mi servidor "**edaddepiedrix**" (como siempre haciendo alusión a la aldea gala)

edaddepiedrix

PRETTY_NAME="KVM Gentoo Linux"
ICON_NAME="gentoo"

**Contraseña de root**

Antes de rearrancar es importante que cambies la contraseña de root.

(chroot) livecd init.d # passwd
New password:
Retype new password:
passwd: password updated successfully

**Preparo el mtab**

Es necesario realizar un link simbólico especial:

# rm /etc/mtab
# ln -sf /proc/self/mounts /etc/mtab

**Instalo Grub 2 como boot loader**

# emerge -v grub:2
:
# grub2-install /dev/sda

Modifico el fichero de configuración de Grub /etc/default/grub, las siguientes son las líneas importantes:

GRUB_CMDLINE_LINUX="init=/usr/lib/systemd/systemd quiet rootfstype=ext4" GRUB_TERMINAL=console GRUB_DISABLE_LINUX_UUID=true

Ah!, en el futuro, cuando te sientas confortable, cambia el timeout del menu que muestra Grub a "0", de modo que ganarás 5 segundos en cada rearranque de tu servidor Gentoo :-)

GRUB_TIMEOUT=0

Cada vez que se modifica el fichero /etc/default/grub hay que ejecutar el programa grub2-mkconfig -o /boot/grub/grub.cfg porque es él el que crea la versión correcta del fichero de configuración de Grub: /boot/grub/grub.cfg.

# mount /boot (por si acaso se te había olvidado :-))
# grub2-mkconfig -o /boot/grub/grub.cfg

Nota, si en el futuro tienes que modificar el Kernel, no olvides ejecutar grub2-mkconfig tras la compilación (y posterior copiado a /boot) del kernel, tampoco te olvides de haber montado /boot (mount /boot) previamente.

**Preparo la red**

{% include showImagen.html
    src="/assets/img/original/). Asigno un nombre específico a la interfaz principal (cambia la MAC a la de tu interfaz"
    caption="upstream"
    width="600px"
    %}

# Interfaz conectada a la red ethernet
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="b8:ae:ed:12:34:56", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"

En la sección de KVM veremos la configuración completa de La Red. De momento creo un fichero bajo /etc/systemd/network, el nombre puede ser cualquiera pero debe terminar en .network. En este caso solo tengo una interfaz física:

#
# Interfaz principal del NUC
#
[Match]
Name=eth0

[Network]
Address=192.168.1.24/24
DNS=192.168.1.1
Gateway=192.168.1.1

A continuación debes habilitar el servicio para el próximo arranque con: systemctl enable systemd-networkd

Otras opciones: * Arrancar manualmente: systemctl start systemd-networkd * Re-arrancar (si cambias algo): systemctl restart systemd-networkd * Verificar: networkctl

 

### Reboot

Salgo del chroot, desmonto y rearranco el equipo...

 
# exit
# cd
# umount -l /mnt/gentoo/dev{/shm,/pts,}
# umount -l /mnt/gentoo{/boot,/proc,}
:
# reboot

 

### Terminar la configuración

Tras el primer reboot nos faltan piezas importantes, vamos a arreglarlo empezando por lo básico.. el teclado :-)

**Teclado y Locale**

Parametrizo con systemd el teclado y los locales ejecutando los tres comandos siguientes:

El primer comando modifica /etc/vconsole.conf

 localectl set-keymap es

El siguiente modifica /etc/X11/xorg.conf.d/00-keyboard.conf

 localectl set-x11-keymap es 

El siguiente modifica /etc/locale.conf

 localectl set-locale LANG=es_ES.UTF-8 

El ultimo simplemente para comprobar

 localectl
System Locale: LANG=es_ES.UTF-8
VC Keymap: es
X11 Layout: es

Preparo el fichero locale.gen

en_US ISO-8859-1
en_US.UTF-8 UTF-8
es_ES ISO-8859-1
es_ES@euro ISO-8859-15
es_ES.UTF-8 UTF-8
en_US.UTF-8@euro UTF-8
es_ES.UTF-8@euro UTF-8

Compilo los "locales"

edaddepiedrix ~ # locale-gen

**Activo SSHD**

Otro indispensable, habilito y arranco el daemon de SSH para poder conectar vía ssh. Si en el futuro quieres poder hacer forward de X11 recuerda poner X11Forwarding yes en el fichero /etc/ssh/sshd_config

# systemctl enable sshd.service

**Vixie-cron**

Instalo, habilito y arranco el cron

edaddepiedrix ~ # emerge -v vixie-cron
edaddepiedrix ~ # systemctl enable vixie-cron.service
edaddepiedrix ~ # systemctl start vixie-cron.service

**Fecha y hora**

{% include showImagen.html
    src="/assets/img/original/?p=881"
    caption="servicio NTP"
    width="600px"
    %}

edaddepiedrix ~ # timedatectl set-local-rtc 0
edaddepiedrix ~ # timedatectl set-timezone Europe/Madrid
edaddepiedrix ~ # timedatectl set-time 2012-10-30 18:17:16 <= Ponerlo primero en hora.
edaddepiedrix ~ # timedatectl set-ntp true <= Activar NTP

 

**Actualizo portage**

Lo primero es hacer un "perl-cleaner" y luego un update completo.

:
edaddepiedrix ~ # perl-cleaner --reallyall
:
edaddepiedrix ~ # emerge --sync
edaddepiedrix ~ #
edaddepiedrix ~ # emerge -DuvN system world

**Usuario y rearranque**

Desde una shell añado un usuario normal y por último rearranco el equipo. Mira un ejemplo:

edaddepiedrix ~ # groupadd -g 1400 luis
edaddepiedrix ~ # useradd -u 1400 -g luis -m -G cron,audio,cdrom,cdrw,users,wheel -d /home/luis -s /bin/bash luis
:
edaddepiedrix ~ # passwd luis
Nueva contraseña:
Vuelva a escribir la nueva contraseña:
:

**Instalo herramientas y paquetes adicionales**

x11-libs/cairo X
dev-libs/libxml2 python

edaddepiedrix ~ # emerge -v mlocate sudo gentoolkit emacs tcpdump traceroute mlocate xclock gparted procmail net-snmp bmon dosfstools sys-boot/syslinux

**nfs-utils para montar volúmenes remotos desde mi NAS**

# emerge -v nfs-utils
:

Tienes dos opciones, utilizar **/etc/fstab** o **automount**.

Ejemplo con /etc/fstab para acceder a recursos remotos NFS.

# Recursos en la NAS via NFS
nas.parchis.org:/NAS  /mnt/NAS  nfs auto,user,exec,rsize=8192,wsize=8192,hard,intr,timeo=5   0 0

Ejemplo usando automount

[Unit]
Description=Montar por NFS el directorio NAS
Wants=network.target rpc-statd.service
After=network.target rpc-statd.service

[Mount]
What=panoramix.parchis.org:/NAS
Where=/mnt/NAS
Options=
Type=nfs
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target

[Unit]
Description=Automount /mnt/NAS

[Automount]
Where=/mnt/NAS

[Install]
WantedBy=multi-user.target

En mi caso prefiero el segundo método:

 
edaddepiedrix ~ # systemctl enable rpcbind.service
edaddepiedrix ~ # systemctl enable mnt-NAS.mount
edaddepiedrix ~ # systemctl enable mnt-NAS.automount
edaddepiedrix ~ # mkdir /mnt/NAS

Por fin, rearranco de nuevo el equipo, deberías tener ya todos los servicios que hemos configurado.

edaddepiedrix ~ # reboot.  (O bien "halt" para pararla)

   

* * *

{% include showImagen.html
    src="/assets/img/original/kvm-1024x324.png"
    caption="kvm"
    width="600px"
    %}

# Configurar la Virtualización con KVM

Ahora que tenemos el linux base (Host) preparado vamos a entrar a configurar KVM. Si estás empezando con esto de KVM verás muchas referencias cruzadas y confusas a KVM y a QEMU, mezclando los conceptos, así que antes de entrar en pista, vamos a ver cual es la diferencia entre KVM y QEmu. Como introducción, recordemos que mi objetivo es conseguir tener un Hypervisor (ahí es donde entra KVM) que se configura en el Kernel y además quiero ejecutar VM's (máquinas virtuales) como invitados (guest) de dicho Hypervisor, y ahí es donde vamos a necesitar instalar QEmu para crear y manipular los guest, las máquinas virtuales, la monitorización, etc.

**QEmu**: es un software completo y autónomo que se utiliza para crear discos, VM's y también para "emular máquinas", es muy flexible y portátil. Además, es capaz de emular una máquina y transformar el código binario escrito para un procesador, por ejemplo permite ejecutar código MIPS en un MacOSX PPC, o ejecutar código ARM en un x86. Si además se quiere emular algo más que solo el procesador, pues incluye un montón de emuladores adicionales: disco, red, VGA, PCI, USB, puertos serie y paralelo, etc.

**KQEmu**: Si queremos emular un x86 en un x86 tenemos un módulo del Kernel que ayuda. El QEmu necesita seguir analizando el código en tiempo real para eliminar cualquier "instrucción privilegiada" y reemplazarlas con cambios de contexto, pero para que sea lo más eficiente posible en x86 hay un módulo del kernel llamado kqemu que se encarga de esto. Al ser un módulo del kernel es más óptimo, tiene que cambiar mucho menos código (ojo que aún así el rendimiento sufre algo).

**KVM**: Por último, KVM son un par de cosas: en primer lugar tenemos un módulo Hypervisor que se activa en el Kernel y que permite poner al equipo en diferentes estados "guest". Dado que solo se trata de un nuevo estado del procesador, el código no hay que cambiarlo. Este módulo del Kernel además se encarga de los registros MMU (utilizados para manejar máquinas virtuales) y emula hardware PCI. En segundo lugar, KVM es un FORK de Qemu y ambos proyectos están muy sincronizados, mientras que QEmu se focaliza en emular Hardware y poder ejecutarlo en qualquier sitio, el equipo de KVM se focaliza exclusivamente en el módulo del Kernel (que por cierto, si QEmu lo detecta automáticamente lo utiliza).

Cuando trabajan de forma conjunta, KVM arbitra el acceso a la CPU y memoria y QEmu emula los recursos del hardware (disco duro, video, USB, etc.). Cuando trabaja solo, QEmu emula tanto la CPU como el Hardware.

**Instalación de KVM y QEmu con todas las herramientas necesarias**

Para KVM no hay que instalar nada, solo configurar el kernel y eso ya lo hice al instalar el Linux (tienes una copia de mi .config más arriba. Lo que sí hay que instalar son las herramientas de gestión de la virtualización (que utilizan QEmu por debajo).

# Cargar el modulo bridge del kernel
bridge

# Cargar el modulo KVM del kernel
kvm_intel
kvm
vhost_net

Preparo los ficheros USE y ejecuto la instalación. Voy a pedir que se instale el programa virt-manager, en realidad es una forma simplificada de decir que se instale todo lo necesario: app-emulation/qemu y app-emulation/libvirt.

# QEMU
net-dns/avahi                        dbus
app-emulation/libvirt                caps libvirtd macvtap nls qemu systemd udev vepa avahi firewalld fuse lxc nfs iscsi
app-emulation/libvirt-glib           python
media-libs/libsdl                    X
app-emulation/virt-manager           gtk
net-libs/gtk-vnc                     python
net-misc/spice-gtk                   python usbredir gtk3
sys-apps/systemd                     gudev
app-emulation/qemu                   aio caps curl fdt filecaps jpeg ncurses nls pin-upstream-blobs png seccomp threads uuid vhost-net vn\
c bluetooth opengl usbredir gtk sdl spice

Ejecuto la instalación de QEMU, virt-manager, libvirt, ebtables (lo necesita libvirtd), creo grupo libvirt y añado mi usuario a los grupos apropiados.

 
edaddepiedrix ~ # emerge -v virt-manager virt-viewer
edaddepiedrix ~ # emerge -v ebtables
edaddepiedrix ~ # groupadd -g 170 libvirt
edaddepiedrix ~ # gpasswd -a luis libvirt
edaddepiedrix ~ # gpasswd -a luis kvm

Modifico la gestión de permisos de libvirt.

 unix_sock_group = "libvirt"
 unix_sock_rw_perms = "0770"

Automatizo el arranque del daemon libvirtd.

 
edaddepiedrix ~ # systemctl enable libvirtd

Es buen momento para hacer reboot y entrar de nuevo con el usuario normal.

 
edaddepiedrix ~ # reboot
:
luis@edaddepiedrix ~ $ 
:

virt-manager es un GUI para gestionar las máquinas virtuales de forma cómoda. Necesita XOrg y en mi caso quiero que funcione vía SSH y ver los gráficos en mi Mac con X11. Si no lo tienes ya instlado hazlo ahora: Instala xclock, xauth para así comprobar todo funciona antes de probar el virt-manager.

edaddepiedrix linux # emerge -v xclock xauth
:
___DESDE MI ESTACIÓN DE TRABAJO, UN MACOS___
obelix:~ luis$ ssh -Y -l root -p 22 edaddepiedrix.parchis.org
root@edaddepiedrix.parchis.org's password:
:
edaddepiedrix linux # xclock
___COMPRUEBA QUE EN EL MAC ARRANCA X11 Y SE VE EL RELOJ___

Compruebo la instalación KVM/QEmu:

luis@edaddepiedrix ~ $ lsmod|grep kvm
kvm_intel             148081  0
kvm                   461126  1 kvm_intel

luis@edaddepiedrix ~ $ virsh -c qemu:///system list
 Id    Nombre                         Estado
——————————————————————————

root@edaddepiedrix ~]# osinfo-query os
 Short ID             | Name                                               | Version  | ID
----------------------+----------------------------------------------------+----------+————————————————————
:
:___ APARECE UNA LISTA ENORME...___

 

## La Red (Hypervisor)

Primero hay que tener claro el diseño físico de la red, qué NIC's tenemos y qué NIC's virtuales van a presentarse (desde KVM) a las VM's. Voy a configurar las vNICs con nombres predecibles, con IPs estáticas (sin dhcp) y que no cambie nada al hacer reboot.

**Conexiones físicas con KVM**

Si empezamos por el diseño físico, es simple, mi Servidor casero, donde se ejecuta Linux Gentoo y el hypervisor KVM, tiene una única tarjeta de red, asi que conecto ese puerto al Switch externo por el cual se entregarán 4 x VLAN's: 2 (iptv), 3 (voip), 6 (internet), 100 (intranet).

{% include showImagen.html
    src="/assets/img/original/hyprevisor-kvm-fisico.png"
    caption="hyprevisor-kvm-fisico"
    width="600px"
    %}

Como voy a recibir 4 VLAN's tengo que configurar 4 virtual switches, cada uno asociado a una VLAN y así poder ofrecérselos a las máquinas virtuales. Es posible hacerlo con Network Manager y de hecho no es demasiado complejo.

### Configuración de varias VLAN's y Bridge's Virtuales

El Hypervisor (KVM) necesita usar el código del Kernel "Bridge", que implementa el estándar ANSI/IEEE 802.1d (en realidad un subconjunto de dicho estándar). Permite crear uno o más bridges lógicos a los que conectaremos las interfaces físicas que deseemos y las lógicas de las máquinas virtuales. En mi caso voy a recibir múltiples VLAN's por una única interfaz física, así que tan sencillo como crear un virtual Switch para cada VLAN y más adelante presentarle al menos una al propio equipo para poder gestionarlo y el resto a la las VM's como desee.

{% include showImagen.html
    src="/assets/img/original/kvmvlan-743x1024.png"
    caption="kvmvlan"
    width="600px"
    %}

Veamos un ejemplo donde el Hypervisor recibe 4 VLAN's:

- WAN (Exterior)
    
    - vlan6 (datos) – MOVISTAR: PPPoE Internet. Aquí conecto una VM: "Firewall"
    - vlan2 (iptv) – MOVISTAR: Servicio IPTV. Aquí conecto una VM: "Firewall"
    - vlan3 (voip) – MOVISTAR: Servicio Voz. Aquí conecto una VM: "Firewall"
- LAN (Interior)
    
    - vlan100 (intranet) – Aquí conecto a este equipo KVM para poder gestionarlo, la VM "Firewall" y otras VM's de mi Intranet.

 

Estos son los ficheros de configuración:

edaddepiedrix network # ls -al
total 108
drwxr-xr-x 2 root root 4096 may 31 12:03 .
drwxr-xr-x 8 root root 4096 may 23 13:17 ..
-rw-r--r-- 1 root root  251 may 24 19:48 eth0.network
-rw-r--r-- 1 root root  115 may 24 18:50 vlan100.netdev
-rw-r--r-- 1 root root   99 may 24 18:58 vlan100.network
-rw-r--r-- 1 root root  109 may 24 19:43 vlan2.netdev
-rw-r--r-- 1 root root   91 may 24 19:43 vlan2.network
-rw-r--r-- 1 root root  109 may 24 19:08 vlan3.netdev
-rw-r--r-- 1 root root   91 may 24 19:10 vlan3.network
-rw-r--r-- 1 root root  109 may 24 19:09 vlan6.netdev
-rw-r--r-- 1 root root   91 may 24 19:31 vlan6.network
-rw-r--r-- 1 root root  171 may 24 18:53 vSwitch100.netdev
-rw-r--r-- 1 root root  509 may 31 11:25 vSwitch100.network
-rw-r--r-- 1 root root  184 may 24 19:12 vSwitch2.netdev
-rw-r--r-- 1 root root  193 may 31 11:26 vSwitch2.network
-rw-r--r-- 1 root root  183 may 24 19:13 vSwitch3.netdev
-rw-r--r-- 1 root root  193 may 31 11:26 vSwitch3.network
-rw-r--r-- 1 root root  185 may 24 19:13 vSwitch6.netdev
-rw-r--r-- 1 root root  193 may 31 11:26 vSwitch6.network

- ETH0

#
# Conecto la interfaz física del NUC a todas las VLAN's
# a las que quiero conectar este Hypervisor, para luego
# poder ofrecérselas a las VM's
#
[Match]
Name=eth0

[Network]
VLAN2=vlan2
VLAN2=vlan3
VLAN2=vlan6
VLAN=vlan100

- VLAN-2

#
# Dispositivo de Red Virtual (netdev) para definir la VLAN 2
#
[NetDev]
Name=vlan2
Kind=vlan

[VLAN]
Id=2

#
# Conecto la vlan2 al bridge "vSwitch2"
#
[Match]
Name=vlan2

[Network]
Bridge=vSwitch2

#
# Bridge Virtual que denomino: "vSwitch2" y que
# utilizaré para todas aquellas VM's que quieran
# tener acceso al servicio de IPTV de Movistar
#
[NetDev]
Name=vSwitch2
Kind=bridge

#
# Para que el Hypervisor pueda conmutar trafico en el Switch2
# es necesario crear vSwitchXXX.network (ademas de vSwitchXXX.netdev)
# y hacer un Match con el vSwitch2
#
[Match]
Name=vSwitch2

- VLAN-3

#
# Dispositivo de Red Virtual (netdev) para definir la VLAN 3
#
[NetDev]
Name=vlan3
Kind=vlan

[VLAN]
Id=3

#
# Conecto la vlan3 al bridge "vSwitch3"
#
[Match]
Name=vlan3

[Network]
Bridge=vSwitch3

#
# Bridge Virtual que denomino: "vSwitch3" y que
# utilizaré para todas aquellas VM's que quieran
# tener acceso al servicio de Voz de Movistar
#
[NetDev]
Name=vSwitch3
Kind=bridge

#
# Para que el Hypervisor pueda conmutar trafico en el Switch3
# es necesario crear vSwitchXXX.network (ademas de vSwitchXXX.netdev)
# y hacer un Match con el vSwitch3
#
[Match]
Name=vSwitch3

- VLAN-6

#
# Dispositivo de Red Virtual (netdev) para definir la VLAN 6
#
[NetDev]
Name=vlan6
Kind=vlan

[VLAN]
Id=6

#
# Conecto la vlan6 al bridge "vSwitch6"
#
[Match]
Name=vlan6

[Network]
Bridge=vSwitch6

#
# Bridge Virtual que denomino: "vSwitch6" y que
# utilizaré para todas aquellas VM's que quieran
# tener acceso al servicio de datos de Movistar
#
[NetDev]
Name=vSwitch6
Kind=bridge

#
# Para que el Hypervisor pueda conmutar trafico en el Switch6
# es necesario crear vSwitchXXX.network (ademas de vSwitchXXX.netdev)
# y hacer un Match con el vSwitch6
#
[Match]
Name=vSwitch6

- VLAN-100

#
# Dispositivo de Red Virtual (netdev) para definir la VLAN 100
#
[NetDev]
Name=vlan100
Kind=vlan

[VLAN]
Id=100

#
# Conecto la vlan100 al bridge "vSwitch100"
#
[Match]
Name=vlan100

[Network]
Bridge=vSwitch100

#
# Bridge Virtual que denomino: "vSwitch100" y que
# utilizaré para todas aquellas VM's que quieran
# tener acceso a la Intranet.
#
[NetDev]
Name=vSwitch100
Kind=bridge

- Dirección IP al Hypervisor KVM para gestionarlo

#
# Para que el Hypervisor pueda conmutar trafico en el Switch100
# es necesario crear vSwitchXXX.network (ademas de vSwitchXXX.netdev)
# y hacer un Match con el vSwitch100
#
[Match]
Name=vSwitch100

# En el caso del Switch100 necesito tener una dirección IP. Es decir,
# El propio Host va a tener una IP en el bridge virtual "vSwitch100",
# de modo que pueda contectar con él para hacer tareas de administración
# desde la intranet.
#
[Network]
Address=192.168.1.24/24
DNS=192.168.1.1
Gateway=192.168.1.1

- Nota: Para que todo esto funcione el Switch "Físico" al cual está conectado este equipo debe tener configurado que me envíe las VLAN's 2,3,6,100
    
- **Rearranco el equipo** y debería funcionarnos todo, aunque no está de más tener cerca virt-manager para acceder a la consola por si acaso :-).
    

:
edaddepiedrix ~ # reboot
:
___TRAS EL ARRANQUE....____
:
edaddepiedrix ~ # ip link
1: lo: mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: tunl0@NONE: mtu 1480 qdisc noop state DOWN mode DEFAULT group default
    link/ipip 0.0.0.0 brd 0.0.0.0
3: sit0@NONE: mtu 1480 qdisc noop state DOWN mode DEFAULT group default
    link/sit 0.0.0.0 brd 0.0.0.0
4: vSwitch6: mtu 1500 qdisc noop state DOWN mode DEFAULT group default
    link/ether d6:6a:3a:cf:82:9a brd ff:ff:ff:ff:ff:ff
5: vSwitch3: mtu 1500 qdisc noop state DOWN mode DEFAULT group default
    link/ether 72:86:17:66:8e:58 brd ff:ff:ff:ff:ff:ff
6: vSwitch2: mtu 1500 qdisc noop state DOWN mode DEFAULT group default
    link/ether c6:c2:36:e5:37:0a brd ff:ff:ff:ff:ff:ff
7: vSwitch100: mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether 0e:24:a8:11:82:c4 brd ff:ff:ff:ff:ff:ff
8: eth0: mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether b8:ae:ed:12:34:56 brd ff:ff:ff:ff:ff:ff
9: vlan3@eth0: mtu 1500 qdisc noqueue master vSwitch3 state UP mode DEFAULT group default
    link/ether e2:5b:76:62:aa:48 brd ff:ff:ff:ff:ff:ff
10: vlan100@eth0: mtu 1500 qdisc noqueue master vSwitch100 state UP mode DEFAULT group default
    link/ether 5e:6d:93:e5:60:93 brd ff:ff:ff:ff:ff:ff
11: vlan2@eth0: mtu 1500 qdisc noqueue master vSwitch2 state UP mode DEFAULT group default
    link/ether ee:12:01:3e:6c:3b brd ff:ff:ff:ff:ff:ff
12: vlan6@eth0: mtu 1500 qdisc noqueue master vSwitch6 state UP mode DEFAULT group default
    link/ether c6:05:7f:d6:4f:68 brd ff:ff:ff:ff:ff:ff
:

edaddepiedrix ~ # brctl show
bridge name bridge id       STP enabled interfaces
vSwitch100      8000.0e24a81182c4   no      vlan100
vSwitch2        8000.c6c236e5370a   no      vlan2
vSwitch3        8000.728617668e58   no      vlan3
vSwitch6        8000.d66a3acf829a   no      vlan6
:

edaddepiedrix ~ # ip addr
1: lo: mtu 65536 qdisc noqueue state UNKNOWN group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: tunl0@NONE: mtu 1480 qdisc noop state DOWN group default
    link/ipip 0.0.0.0 brd 0.0.0.0
3: sit0@NONE: mtu 1480 qdisc noop state DOWN group default
    link/sit 0.0.0.0 brd 0.0.0.0
4: vSwitch6: mtu 1500 qdisc noop state DOWN group default
    link/ether d6:6a:3a:cf:82:9a brd ff:ff:ff:ff:ff:ff
5: vSwitch3: mtu 1500 qdisc noop state DOWN group default
    link/ether 72:86:17:66:8e:58 brd ff:ff:ff:ff:ff:ff
6: vSwitch2: mtu 1500 qdisc noop state DOWN group default
    link/ether c6:c2:36:e5:37:0a brd ff:ff:ff:ff:ff:ff
7: vSwitch100: mtu 1500 qdisc noqueue state UP group default
    link/ether 0e:24:a8:11:82:c4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.24/24 brd 192.168.1.255 scope global vSwitch100
       valid_lft forever preferred_lft forever
    inet6 fe80::c24:a8ff:fe11:82c4/64 scope link
       valid_lft forever preferred_lft forever
8: eth0: mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether b8:ae:ed:12:34:56 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::baae:edff:fe12:3456/64 scope link
       valid_lft forever preferred_lft forever
9: vlan3@eth0: mtu 1500 qdisc noqueue master vSwitch3 state UP group default
    link/ether e2:5b:76:62:aa:48 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::e05b:76ff:fe62:aa48/64 scope link
       valid_lft forever preferred_lft forever
10: vlan100@eth0: mtu 1500 qdisc noqueue master vSwitch100 state UP group default
    link/ether 5e:6d:93:e5:60:93 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::5c6d:93ff:fee5:6093/64 scope link
       valid_lft forever preferred_lft forever
11: vlan2@eth0: mtu 1500 qdisc noqueue master vSwitch2 state UP group default
    link/ether ee:12:01:3e:6c:3b brd ff:ff:ff:ff:ff:ff
    inet6 fe80::ec12:1ff:fe3e:6c3b/64 scope link
       valid_lft forever preferred_lft forever
12: vlan6@eth0: mtu 1500 qdisc noqueue master vSwitch6 state UP group default
    link/ether c6:05:7f:d6:4f:68 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::c405:7fff:fed6:4f68/64 scope link
       valid_lft forever preferred_lft forever 

# Las Máquinas virtuales

Ya queda menos, el siguiente paso consiste en crear, modificar, borrar, etc. las máquinas virtuales. Podemos usar la línea de comandos o virt-manager.

Ten en cuenta que las interfaces que he configurado en el Host (Hypervisor) con soporte de VLAN's se presentarán a las máquinas virtuales sin el tag VLAN y podrás conectar a cualquiera de ellas (o a todas) desde virt-manager

{% include showImagen.html
    src="/assets/img/original/intfVirtuales.png"
    caption="intfVirtuales"
    width="600px"
    %}

### virt-manager

Con virt-manager las VM's se crearán por defecto en el directorio /var/lib/libvirt/images. Recordemos que tendrán la extensión .qcow2. Veamos el ejemplo completo:

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm1.png"
    caption="kvm-new-vm1"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm2.png"
    caption="kvm-new-vm2"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm3.png"
    caption="kvm-new-vm3"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm4.png"
    caption="kvm-new-vm4"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm5.png"
    caption="kvm-new-vm5"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm6.png"
    caption="kvm-new-vm6"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm7.png"
    caption="kvm-new-vm7"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm8-1.png"
    caption="kvm-new-vm8-1"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm8-2.png"
    caption="kvm-new-vm8-2"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm8-3.png"
    caption="kvm-new-vm8-3"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm9.png"
    caption="kvm-new-vm9"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm10-1024x915.png"
    caption="kvm-new-vm10"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm12-1024x919.png"
    caption="kvm-new-vm12"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm13-1024x918.png"
    caption="kvm-new-vm13"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-new-vm14.png"
    caption="kvm-new-vm14"
    width="600px"
    %}

 

### Comandos y trucos

Siempre tendremos la opción de manipular las máquinas virtuales usando la línea de comandos, veamos unos ejemplos:

- Creación de una máquina virtual. Utilizo la herramienta virt-install, crearé un copia de Centos7 en el directorio /var/lib/libvirt/images.

edaddepiedrix ~ # virt-install \
 -n myOtroCentos7 \
 --description "Mi otro Centos7" \
 --os-type=Linux \
 --os-variant=centos7.0 \
 --ram=2048 \
 --vcpus=2 \
 --disk path=/var/lib/libvirt/images/myOtroCentos7.img,bus=virtio,size=10 \
 --cdrom /datastore/iso/CentOS-7-x86_64-DVD-1503-01.iso \
 --network bridge:vSwitch100

NOTA: Si devuelve un error de permisos, ejecuta el siguiente comando: 
edaddepiedrix ~ # chown -R qemu:qemu /var/lib/libvirt/qemu

La instalación será desatendida si el "ISO" es capaz de hacerlo (de hecho podríamos pasarle el argumento \--graphics none, en caso contrario, una vez lanzado, podremos conectar desde otro terminal, ejecutar virt-manager, conectar con la máquina virtual, abrir su consola y repetir lo mismo que hicimos en la instalación gráfica.

- Mostrar las máquinas virtuales

edaddepiedrix ~ # virsh list --all
 Id    Nombre                         Estado
----------------------------------------------------
 7     myOtroCentos7                  ejecutando
 - centos7                        apagado

- Editar el fichero XML de configuración de una máquina virtual

edaddepiedrix ~ # e /etc/libvirt/qemu/centos7.xml 
:
o mejor, 
:
edaddepiedrix ~ # virsh edit centos7

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**AVISO**: Los ficheros de configuración residen en /etc/libvirt/qemu y deberías guardarte copias de seguridad.

[/dropshadowbox]

{% include showImagen.html
    src="/assets/img/original/kvmConfigs.png"
    caption="kvmConfigs"
    width="600px"
    %}

- Mostrar información sobre una máquina virtual

edaddepiedrix ~ # virsh dominfo centos7
Id:             -
Nombre:         centos7
UUID:           0ac8a9aa-e15b-4ac0-b73b-6d46a729fcc1
Tipo de sistema operatuvo: hvm
Estado:         apagado
CPU(s):         2
Memoria máxima: 2097152 KiB
Memoria utilizada: 0 KiB
Persistente:    si
Autoinicio:     desactivar
Guardar administrado: no
Modelo de seguridad: none
DOI de seguridad: 0

- Arrancar una máquina virtual

edaddepiedrix ~ # virsh start centos7
Se ha iniciado el dominio centos7

- Programar su arranque automático (autostart)

edaddepiedrix ~ # virsh autostart aplicacionix
El dominio aplicacionix se ha configurado para iniciarse automáticamente
edaddepiedrix ~ # virsh autostart cortafuegix
El dominio cortafuegix se ha configurado para iniciarse automáticamente

- Consumo real de memoria de una máquina virtual "con Linux"

Si no estás seguro de cuanta memoria deberías asignarle a tu VM con Linux, el siguiente truco te va a venir bien. Utiliza el comando "free" y fíjate en la línea que pone \-/+ buffers/cache: y las columnas used y free. En el ejemplo siguiente vemos que la VM tiene asignados 8GB (7990), está usando 2,7GB (2795) y tiene libres 5GB (5194). En este caso tiene pinta de que si asigno 4GB a la VM tengo más que de sobra y no desperdicio tanta memoria.

aplicacionix ~ # free -m
             total       used       free     shared    buffers     cached
Mem:          7990       4970       3020         17        123       2050
-/+ buffers/cache:       2795       5194
Swap:          511          0        511

- Reboot de una máquina virtual

edaddepiedrix ~ # virsh reboot centos7
El dominio centos7 está siendo reiniciado

- Apagar una máquina virtual

edaddepiedrix ~ # virsh shutdown centos7
El dominio centos7 está siendo apagado

- Conectar con la consola de una máquina virtual usando virt-viewer

luis@edaddepiedrix ~ $ virt-viewer --connect qemu:///system

{% include showImagen.html
    src="/assets/img/original/virtviewer-1024x829.png"
    caption="virtviewer"
    width="600px"
    %}

- Redimensionar el disco duro de la VM

Parar la VM

edaddepiedrix luis # virsh shutdown aplicacionix

Redimensionar la imagen del disco duro

luis@edaddepiedrix ~ $ qemu-img resize aplicacionix.qcow2 +10GB
Image resized.

{% include showImagen.html
    src="/assets/img/original/download.php"
    caption="LiveCD de GParted"
    width="600px"
    %}

luis@edaddepiedrix ~ # virsh edit aplicacionix

Buscar la línea que pone: y cambiar por

Añadir un CDROM después del disco duro:

     

Arrancar la máquina virtual y usar GParted para redimensionar la partición. Una vez que terminas ya puedes desahacer la configuración anterior y boot de forma normal.

{% include showImagen.html
    src="/assets/img/original/livegparted.png"
    caption="livegparted"
    width="600px"
    %}

 

### Migrar máquina virtual desde ESXi

A continuación muestro un ejemplo de migraicón de una máquina virtual desde ESXi hacia KVM. El proceso que voy a seguir consiste en migrar el fichero .vmdk a .qcow2

- Paro la máquina virtual en ESXi.
- Hago un backup a OVF
- Convierto el fichero "disco", veamos un ejemplo:

edaddepiedrix ~ # qemu-img convert -O qcow2 Gentoo_403-disk1.vmdk gentoo.qcow2

- Desde virt-manager crear la VM importando desde el .qcow2

 

## Gestión de las máquinas virtuales

{% include showImagen.html
    src="/assets/img/original/Management_Tools"
    caption="esta página"
    width="600px"
    %}

* * *

 

## iSCSI

Para conectar con targets iSCSI y que tus VM's puedan consumir desde una NAS, necesitas realizar varias acciones:

- Configurar el soporte de iSCSI en el Kernel
    
- Compilar app-emulation/libvirt con el USE=iscsi.
    
- Averiguar el InitiatorName de este equipo
    

marte ~ # iscsi-iname
iqn.2005-03.org.open-iscsi:dc2484682b10

- Configurar el InitiatorName en el fichero /etc/iscsi/initiatorname.iscsi

InitiatorName=iqn.2005-03.org.open-iscsi:dc2484682b10
InitiatorAlias=marte

- Activar el servicio iscsid

[Unit]
Description=Open-iSCSI
Documentation=man:iscsid(8) man:iscsiuio(8) man:iscsiadm(8)
After=network.target NetworkManager-wait-online.service iscsiuio.service tgtd.service targetcli.service

[Service]
Type=forking
PIDFile=/var/run/iscsid.pid
ExecStart=/usr/sbin/iscsid
ExecStop=/sbin/iscsiadm -k 0 2

[Install]
WantedBy=multi-user.target

[Unit]
Description=Open-iSCSI iscsid Socket
Documentation=man:iscsid(8) man:iscsiuio(8) man:iscsiadm(8)

[Socket]
ListenStream=@ISCSIADM_ABSTRACT_NAMESPACE

[Install]
WantedBy=sockets.target

Ejemplo de post-script para hacer login automáticamente los targets

[Unit]
Description=Script post iSCSI
Wants=iscsid.service
After=iscsid.service

[Service]
Type=oneshot
ExecStart=/bin/bash /root/iscsi/iscsi_start.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

#!/bin/bash
#
iSCSI_SERVER="192.168.1.122"
TARGETS="iqn.2004-04.com.qnap:ts-569pro:iscsi.maquina.d70ea1 \
         iqn.2004-04.com.qnap:ts-569pro:iscsi.prueba.d70ea1"

for TARGET in ${TARGETS}; do

    found=\`iscsiadm -m session | grep -i ${TARGET}\`
    if [ "${found}" = "" ]; then
        iscsiadm -m node -T ${TARGET} -p ${iSCSI_SERVER} --login
    fi
done

 

#### Backup datos persistentes en disco iSCSI

{% include showImagen.html
    src="/assets/img/original/?p=18"
    caption="RBME: Backup incremental en Linux"
    width="600px"
    %}
