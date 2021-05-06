---
title: "Mi próximo servidor casero"
date: "2014-10-20"
categories: gentoo
tags: d54250wyk linux nuc servidor
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/Main_Page), etc"
    caption="kvm"
    width="600px"
    %}

## Hardware

{% include showImagen.html
    src="/assets/img/original/"
    caption="pccomponentes.com"
    width="600px"
    %}

- 1.- Kit Mini ordenador (que incluye lo siguiente)
{% include showImagen.html
    src="/assets/img/original/intel_nuc_d54250wyk.html)"
    caption="D54250WYK](http://www.intel.es/content/www/es/es/nuc/nuc-kit-d54250wyk.html) 4ª Gen, con placa [D34010WYB](http://downloadmirror.intel.com/23090/eng/D54250WYB_D34010WYB_TechProdSpec06.pdf) ([340€"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/Intel-Core-i5-4250U-Processor-3M-Cache-up-to-2_60-GHz"
    caption="Core i5-4250U"
    width="600px"
    %}
    - NIC Intel I218V GE (**IMPORTANTE: soporta VLAN y modo promiscuo**).
    - Interfaz SATA con soporte AHCI
    - Intel(R) PRO/1000 PCI-Express Gigabit Ethernet
- 2.- RAM 16GB (2 x 8GB SO-DIMM DDR3L 1600/1333 MHz 1,35 V)
{% include showImagen.html
    src="/assets/img/original/memCertPartSearchResultsAll.asp?bNav=True&sManuf=Intel&outside=False&sMN=D54250WYB%2FD54250WYK%2FD54250WYKH&oSubmit=Search)"
    caption="CMTL"
    width="600px"
    %}
- 3.- Disco SSD mSATA de 240GB
{% include showImagen.html
    src="/assets/img/original/CS-034605.htm#peripherals)"
    caption="CT240M500SSD3](http://eu.crucial.com/ProductDisplay?urlRequestType=Base&catalogId=10152&categoryId=&productId=12919&urlLangId=-1&langId=-1&top_category=&parent_category_rn=&storeId=10152) ([104€](http://www.pccomponentes.com/crucial_m500_240gb_ssd_msata.html)) ([Certificado"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/equip_cable_hdmi_1_4_a_mini_hdmi_1m.html)"
    caption="4.25€"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/cable_alimentacion_trebol_a_schuko_1_8m.html)"
    caption="2,95€"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/NUC-D54250WYK.jpg"
    caption="NUC-D54250WYK"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/CS-034605.htm#peripherals"
    caption="recomendados y probados por Intel"
    width="600px"
    %}

## Software

En la parte de software después de 20 años no voy a abandonar GNU/Linux, pero como "novedad" si que adelanto que voy a investigar, aprender e implementar un par de cosas adicionales: Docker y probablemente VMware ESXi.

{% include showImagen.html
    src="/assets/img/original/?p=7"
    caption="aquí he dejado el proceso de instalación"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=172"
    caption="varios servicios dockerizados"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=1803) con aplicaciones Dockerizadas :-"
    caption="Gentoo VM sobre ESXi"
    width="600px"
    %}

### Actualización

En Mayo 2015 probé con resultado satisfactorio pude probar el nuevo Intel® NUC (5ª generación): NUC5i5RYK, con las mismas memorias Kingston 8GB DDR3 1600MHz PC3L-12800 SO-DIMM y disco duro Samsung 850 Evo SSD Series 500GB mSATA 1.8".
