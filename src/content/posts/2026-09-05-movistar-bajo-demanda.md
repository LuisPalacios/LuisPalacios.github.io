---
title: "Vídeo bajo demanda"
date: "2026-09-05"
categories: ["linux"]
tags: ["movistar", "router", "cone", "nat", "iptables", "rtsp", "television"]
draft: false
cover:
  image: "/img/posts/logo-linux-rtsp.svg"
  hidden: true
---

<img src="/img/posts/logo-linux-rtsp.svg" alt="logo linux router" width="150px" height="150px" style="float:left; padding-right:25px"  />

Los canales normales de Movistar TV viajan en **Multicast/UDP**, pero todo lo que pides tú
—una peli del videoclub, rebobinar lo que están echando, una grabación de la nube— viaja en
**Unicast**, y ahí es donde un router Linux casero se atraganta. En este apunte cuento cómo
funciona ese tráfico **hoy**, medido con la tele puesta, y qué hay que poner en el router para
que se vea. Hay una sorpresa: ya no todo usa `RTSP`.

Hace más de una década escribí [Video bajo demanda para Movistar]({{< relref "2014-10-18-movistar-bajo-demanda.md" >}}),
la primera vez que me peleé con esto en mi [router Linux]({{< relref "2014-10-05-router-linux.md" >}}).
Recientemente me dio por verificar si `igmpproxy` y el helper `RTSP` del kernel seguían haciendo
falta, le di una vuelta al asunto, y de ahí sale este apunte. Sí, me aburría y me dió por hacer un estudio académico.

<br clear="left"/>
<!--more-->

## No hay un «vídeo bajo demanda», hay tres

Durante años todo lo que no era un canal en directo funcionaba igual: el deco pedía el vídeo
por `RTSP` y le llegaba un `MPEG-TS` crudo por `UDP`. Hoy **eso ya no es cierto**, y conviene
saberlo antes de pelearse con el router, porque explica por qué a veces parece que el helper
del kernel «no hace nada».

Lo medí camino por camino, poniendo a cero el contador de la regla del firewall antes de cada
prueba y lanzando cada cosa desde el mando:

| Lo que pides desde el mando       | Cómo viaja hoy                     | ¿Necesita ayuda en el router? |
| --------------------------------- | ---------------------------------- | ----------------------------- |
| **Una peli del videoclub**        | **HTTP sobre TCP 80**, en trocitos | **No**                        |
| **Rebobinar el canal en directo** | **RTSP + MPEG-TS por UDP**         | **Sí**                        |
| **Una grabación de la nube**      | **RTSP + MPEG-TS por UDP**         | **Sí**                        |

El videoclub se ha pasado a la entrega tipo _OTT_: el deco abre un montón de conexiones HTTP
cortas y va pidiendo el vídeo a trozos, igual que hace Netflix o YouTube. Eso atraviesa
cualquier router sin ayuda, porque es tráfico normal: sale una petición, vuelve una respuesta.

Los otros dos siguen con el método clásico, y ése es el que da guerra.

<div class="image-box">
  <img src="/img/posts/2026-09-05-movistar-bajo-demanda-01.png" alt="Los tres caminos del vídeo bajo demanda" width="700px" />
  <div class="image-caption">Los tres caminos: solo dos necesitan ayuda en el router</div>
</div>

**Ojo con una trampa.** Si miras el contador de la regla del firewall y está a cero, es muy
tentador concluir que el helper ya no sirve para nada. A mí me pasó: llevaba **13 horas con la
tele encendida y cero paquetes**. No significaba que sobrara, significaba que en esas 13 horas
nadie había rebobinado ni abierto una grabación. En cuanto rebobiné, el contador empezó a
subir.

## El problema

Imagina que llamas por teléfono a una empresa para pedir un paquete. Durante la llamada les
dices: «mándenmelo al portal número 27392». Cuelgas, y al rato llega el repartidor a ese
portal.

El portero automático de tu edificio (el **router**, haciendo NAT) tiene una norma sencilla:
solo deja entrar a quien viene a responder a algo que salió de dentro. Y aquí está el
problema: **el número de portal se dijo hablando, dentro de la conversación**. El portero no
escuchó la llamada, así que cuando aparece el repartidor no tiene ni idea de quién es ni a
quién va, y le da con la puerta en las narices.

Resultado: la grabación «no arranca» y el deco te enseña un error genérico.

<div class="image-box">
  <img src="/img/posts/2026-09-05-movistar-bajo-demanda-02.png" alt="Por qué el router tira el vídeo" width="700px" />
  <div class="image-caption">El puerto se anuncia hablando, no abriéndolo: el NAT no se entera</div>
</div>

La solución es enseñarle al portero a **escuchar la conversación**. Eso es exactamente lo que
hacen los dos módulos de kernel de los que va este apunte: leen el diálogo `RTSP`, se enteran
del número de portal y dejan la puerta preparada **antes** de que llegue el repartidor.

## Cómo es la conversación, paso a paso

Cuando le das a «Ver» en una grabación, esto es lo que pasa:

1. El deco pregunta al **DNS** de Movistar (`172.26.23.3`) quién sirve ese contenido.
2. Abre una conversación **RTSP** contra ese servidor, en el puerto **TCP 554**.
3. Pide el vídeo con un mensaje `SETUP` que lleva esta línea:

   ```text
   Transport: MP2T/H2221/UDP;unicast;client_port=27392
   ```

   Ahí está el número de portal: **27392**.

4. El servidor contesta, y aquí viene el primer detalle interesante:

   ```text
   Transport: MP2T/H2221/UDP;unicast;destination=<tu IP>;server_port=49980;client_port=27392
   ```

   Fíjate en **`server_port=`**: el servidor te dice desde qué puerto va a emitir. Antes no lo
   decía.

5. El servidor empieza a mandar el `MPEG-TS` por `UDP` a ese puerto 27392, y se ve la imagen.
6. El deco mantiene la conversación viva con mensajes `GET_PARAMETER` de vez en cuando, y al
   terminar manda `TEARDOWN`.

<div class="image-box">
  <img src="/img/posts/2026-09-05-movistar-bajo-demanda-03.png" alt="La conversación RTSP paso a paso" width="700px" />
  <div class="image-caption">Del «Ver» a la imagen: la conversación completa</div>
</div>

### La sorpresa: el vídeo viene del mismo sitio

Durante años, la explicación de por qué esto era difícil decía: «el deco habla con un servidor
de control, pero **el vídeo lo manda otra máquina distinta, con una IP que tu router no
conoce**». De ahí venía la fama de que hacía falta _full cone NAT_, que es abrir la puerta de
par en par.

**Hoy ya no es así.** Lo he comprobado en tres sesiones distintas, comparando quién atiende el
554 con quién manda el `UDP`:

| Sesión          | Servidor RTSP | Quién manda el vídeo | ¿El mismo? |
| --------------- | ------------- | -------------------- | ---------- |
| Rebobinado, 1.ª | `172.26.83.a` | `172.26.83.a`        | sí         |
| Rebobinado, 2.ª | `172.26.83.b` | `172.26.83.b`        | sí         |
| Grabación       | `172.26.83.c` | `172.26.83.c`        | sí         |

Movistar ha juntado las dos cosas en la misma máquina, y encima lo anuncia en `server_port=`.
Eso hace el problema **más fácil** de lo que era… y también más frágil, como cuento al final.

## Cómo se implementa en Linux

Se hace con dos módulos de kernel, `nf_conntrack_rtsp` y `nf_nat_rtsp`, que son el «portero que
escucha». El primero sigue la conversación y apunta «va a llegar un UDP al portal 27392, déjalo
pasar»; el segundo se encarga de la traducción cuando hay NAT por medio. Son los mismos de
aquel apunte de 2014, solo que hoy se instalan y se activan de otra manera.

### Compilar e instalar

Lo importante hoy es **no instalarlos a mano**. Un módulo de kernel compilado a mano deja de
existir en cuanto actualizas el kernel, y te quedas sin grabaciones **en silencio**: el directo
sigue yendo, así que no te enteras hasta que alguien intenta ver algo.

Los fuentes están en [mi repositorio rtsp-linux en GitHub](https://github.com/LuisPalacios/rtsp-linux),
el mismo de 2014. Tengo pendiente subir la versión nueva, con las mejoras de estas pruebas y la
configuración de DKMS, junto con un `igmpproxy` también mejorado. La forma correcta de
instalarlos es **DKMS**, que los recompila solo cada vez que entra un kernel nuevo, durante el
propio `apt`:

```shell
# Se registra el paquete y se construye para el kernel actual
sudo dkms add    ./rtsp-helper
sudo dkms build  rtsp-helper/<version>
sudo dkms install rtsp-helper/<version>

# Comprobar que ha quedado bien
dkms status
# rtsp-helper/<version>, 6.x.y-generic, x86_64: installed
```

A partir de ahí te olvidas. Yo lo he visto funcionar en real: entre que lo instalé y que
reinicié, la máquina actualizó de kernel, y DKMS había reconstruido los módulos para el nuevo
sin que yo hiciera nada.

### Cargarlos al arrancar

En Debian/Ubuntu, añade al fichero `/etc/modules`:

```shell
nf_nat_rtsp
```

Con poner ése basta: arrastra al otro como dependencia.

### Decirle al kernel que los use

Tener los módulos cargados no basta: hay que decirle al kernel que aplique el helper a las
conversaciones `RTSP`. Este paso se olvida siempre y es el que más ratos de depuración cuesta.
Hay dos formas, según la versión del kernel:

```shell
# Kernel < 6 (ya en desuso)
sysctl -w net.netfilter.nf_conntrack_helper=1

# Kernel >= 6: la única que funciona hoy
iptables -t raw -A PREROUTING -p tcp --dport 554 -j CT --helper rtsp
```

En los kernels modernos **la asignación automática de helpers ya no existe**, así que la regla
del `raw` no es opcional. Acuérdate de ejecutarla en el arranque, y no dos veces desde dos
sitios distintos.

Y el tráfico de los decos hacia Movistar tiene que salir enmascarado:

```shell
iptables -t nat -A POSTROUTING -o <interfaz de IPTV> -j MASQUERADE
```

## ¿Y si pauso media hora?

Ésta era mi gran duda, y tenía toda la pinta de ser el punto débil del montaje.

El razonamiento era: mientras se reproduce, el vídeo va llegando y el router mantiene fresca la
anotación de «este UDP va para el deco». Pero si pausas, deja de llegar vídeo, la anotación
caduca **a los 30 segundos**, y el permiso que abrió la puerta era de **un solo uso**: se gastó
con el primer paquete. Al reanudar, el deco no vuelve a pedir permiso —manda un simple `PLAY`
sobre la conversación que ya tenía—, así que el vídeo llegaría a una puerta cerrada.

Suena impecable. **Pues no pasa.** Pausé una grabación seis minutos, y otra ocho, y en las dos
la imagen volvió **instantánea**.

La razón la encontré midiendo cada 5 segundos cuánta vida le quedaba a la anotación del router:

```text
09:07:04   le quedan 119 s
09:08:05   le quedan 119 s   ← se ha renovado
09:09:05   le quedan 118 s   ← otra vez
09:10:06   le quedan 118 s   ← cada 60 segundos exactos
```

Algo la renovaba cada minuto. Capturando con una ventana más ancha que ese minuto apareció el
culpable:

```text
09:12:04  IP <tu router>.27392 > <servidor>.49980: UDP, length 3
```

**Es el propio deco.** Mientras está pausado manda un paquete de **3 bytes cada 60 segundos**
al servidor, por el mismo par de puertos del vídeo. Es un truco clásico: mantener la puerta
abierta pasando el pie por ella de vez en cuando.

<div class="image-box">
  <img src="/img/posts/2026-09-05-movistar-bajo-demanda-04.png" alt="El keepalive del deco durante la pausa" width="700px" />
  <div class="image-caption">Pausado, el deco mete el pie en la puerta cada 60 segundos</div>
</div>

Tiene un efecto secundario simpático: como ahora hay tráfico en los dos sentidos, el router
deja de tratarlo como «conversación a medias» y le sube el plazo **de 30 a 120 segundos**. O
sea que el margen todavía es mayor.

Conclusión práctica: **puedes pausar lo que quieras**. Pero conviene saber que quien te salva
es el deco, no tu router. Un corte de la VPN de más de dos minutos sí que cortaría el vídeo,
porque entonces el que mete el pie en la puerta está al otro lado del corte.

## Monitorizar: qué mirar y en qué orden

Cuando algo no se ve, sigue siempre el mismo orden, de lo más básico a lo más fino, y con una
grabación puesta en la tele:

```shell
# 1. ¿Están los módulos cargados?
lsmod | grep rtsp

# 2. ¿Está la regla, y ha visto pasar algo? (mira el contador)
iptables -t raw -L PREROUTING -v -n | grep 'CT helper'

# 3. ¿Hay conversación RTSP abierta, y llega el vídeo?
conntrack -L -p tcp --dport 554
conntrack -L -p udp | grep 'src=172\.26\.'
```

Si con eso no lo ves claro, `tcpdump` sobre el puerto 554 te enseña la conversación entera, y
el módulo puede contarte lo que piensa por `dmesg` sin recompilarlo: en un kernel con
`CONFIG_DYNAMIC_DEBUG=y` el debug del módulo se enciende y se apaga en caliente.

## Lo que puede romperse el día de mañana

Tres cosas, y ninguna depende de ti:

1. **El permiso que abre la puerta es más estrecho de lo que parece.** No es un _full cone_
   de verdad: acepta que el vídeo venga desde cualquier puerto, pero **exige que venga
   exactamente de la IP del servidor con el que hablaste por RTSP**. Hoy funciona porque son
   la misma máquina. Si Movistar volviera a separarlas, dejaría de verse **aunque todo lo
   demás estuviera perfecto**, y el síntoma sería desconcertante: la conversación RTSP se
   establece sin problemas y aun así no hay imagen.
2. **La pausa la salva el deco.** Un modelo de deco que no mandara ese paquete de 3 bytes
   volvería a exponer el problema entero.
3. **Puede que un día esto no haga falta.** El videoclub ya se ha ido a HTTP. Si el rebobinado
   y las grabaciones siguen el mismo camino, estos módulos dejarán de tener sentido. Pero
   **hoy siguen siendo imprescindibles**, así que no los quites por lo que leas en un contador
   a cero.

## Resumen

- Hay **tres** caminos, no uno: el videoclub va por HTTP y no necesita nada; el rebobinado y
  las grabaciones van por RTSP y sí lo necesitan.
- El router tira el vídeo porque el puerto se anuncia **hablando**, y hay que enseñarle a
  escuchar: `nf_conntrack_rtsp` + `nf_nat_rtsp`.
- Instálalos con **DKMS**, no a mano, o el próximo kernel te dejará sin grabaciones en
  silencio.
- En kernel ≥ 6, la regla `iptables -t raw ... -j CT --helper rtsp` **no es opcional**.
- Pausar no rompe nada, y el mérito es del deco.

## Referencias

- Mi repositorio [rtsp-linux](https://github.com/LuisPalacios/rtsp-linux) con los módulos `nf_conntrack_rtsp` y `nf_nat_rtsp`. Pendiente de subir la versión con DKMS y el `igmpproxy` mejorado.
- El apunte original de 2014: [Video bajo demanda para Movistar]({{< relref "2014-10-18-movistar-bajo-demanda.md" >}}).
