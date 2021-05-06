---
title: "Mi próximo servidor casero"
date: "2014-10-20"
categories: gentoo
tags: d54250wyk linux nuc servidor
excerpt_separator: <!--more-->
---

Estas son mis notas sobre el resultado de una investigación para decidir cual será mi próximo "Home Server". El objetivo diría que es el de siempre, convertirlo en el servidor que hace de [router con Internet](https://www.luispa.com/?p=266) y gestiona algunos servicios como mi correo privado y este pequeño [blog](https://www.luispa.com). En realidad es una excusa, el verdadero objetivo es mi continuo aprendizaje sobre GNU/Linux (y otras cosas como [docker](https://www.luispa.com/?p=874), [esxi](https://www.luispa.com/?p=29), ![kvm](/assets/img/original/Main_Page), etc){: width="730px" padding:10px }.

## Hardware

Escogí la solución Intel® NUC (4ª generación), me salió por unos 600€ (_**Precios de Octubre de 2014**_), he comprado todo en ![pccomponentes.com](/assets/img/original/){: width="730px" padding:10px }, muy contento con tiempo de entrega y soporte.

- 1.- Kit Mini ordenador (que incluye lo siguiente)
![D54250WYK](http://www.intel.es/content/www/es/es/nuc/nuc-kit-d54250wyk.html) 4ª Gen, con placa [D34010WYB](http://downloadmirror.intel.com/23090/eng/D54250WYB_D34010WYB_TechProdSpec06.pdf) ([340€](/assets/img/original/intel_nuc_d54250wyk.html)){: width="730px" padding:10px }
    - CPU Intel Haswell ![Core i5-4250U](/assets/img/original/Intel-Core-i5-4250U-Processor-3M-Cache-up-to-2_60-GHz){: width="730px" padding:10px } 64bits, 4 threads, 1.3-2.6 GHz
    - NIC Intel I218V GE (**IMPORTANTE: soporta VLAN y modo promiscuo**).
    - Interfaz SATA con soporte AHCI
    - Intel(R) PRO/1000 PCI-Express Gigabit Ethernet
- 2.- RAM 16GB (2 x 8GB SO-DIMM DDR3L 1600/1333 MHz 1,35 V)
    - 2x8GB [Kingston KVR16LS11/8](http://www.kingston.com/dataSheets/KVR16LS11_8.pdf) ([148.00€](http://www.pccomponentes.com/kingston_8gb_ddr3_1600mhz_pc3l_12800_so_dimm.html)) ([Certificada](http://www.intel.com/support/sp/motherboards/desktop/sb/CS-034475.htm) y por ![CMTL](/assets/img/original/memCertPartSearchResultsAll.asp?bNav=True&sManuf=Intel&outside=False&sMN=D54250WYB%2FD54250WYK%2FD54250WYKH&oSubmit=Search)){: width="730px" padding:10px }
- 3.- Disco SSD mSATA de 240GB
![CT240M500SSD3](http://eu.crucial.com/ProductDisplay?urlRequestType=Base&catalogId=10152&categoryId=&productId=12919&urlLangId=-1&langId=-1&top_category=&parent_category_rn=&storeId=10152) ([104€](http://www.pccomponentes.com/crucial_m500_240gb_ssd_msata.html)) ([Certificado](/assets/img/original/CS-034605.htm#peripherals)){: width="730px" padding:10px }
![4.25€](/assets/img/original/equip_cable_hdmi_1_4_a_mini_hdmi_1m.html)){: width="730px" padding:10px }
![2,95€](/assets/img/original/cable_alimentacion_trebol_a_schuko_1_8m.html)){: width="730px" padding:10px }

![NUC-D54250WYK](/assets/img/original/NUC-D54250WYK.jpg){: width="730px" padding:10px }

![recomendados y probados por Intel](/assets/img/original/CS-034605.htm#peripherals){: width="730px" padding:10px }.

## Software

En la parte de software después de 20 años no voy a abandonar GNU/Linux, pero como "novedad" si que adelanto que voy a investigar, aprender e implementar un par de cosas adicionales: Docker y probablemente VMware ESXi.

- [GNU](http://www.gnu.org)/[Linux](http://www.kernel.org): Sistema operativo base (uso la distro [Gentoo](http://www.gentoo.org/doc/es/handbook/)) y ![aquí he dejado el proceso de instalación](/assets/img/original/?p=7){: width="730px" padding:10px }
- [Docker](https://www.luispa.com/?p=874): Aplicaciones empaquetadas en contenedores auto suficientes, consultá este apunte que hice sobre ![varios servicios dockerizados](/assets/img/original/?p=172){: width="730px" padding:10px }
- [VMWare ESXi](https://www.luispa.com/?p=29): Instalaré [ESXi como Hypervisor](https://www.luispa.com/?p=29) y pondré encima varias VM's, entre ellas una ![Gentoo VM sobre ESXi](/assets/img/original/?p=1803) con aplicaciones Dockerizadas :-){: width="730px" padding:10px }

### Actualización

En Mayo 2015 probé con resultado satisfactorio pude probar el nuevo Intel® NUC (5ª generación): NUC5i5RYK, con las mismas memorias Kingston 8GB DDR3 1600MHz PC3L-12800 SO-DIMM y disco duro Samsung 850 Evo SSD Series 500GB mSATA 1.8".
