## 📊 Material Alternate Unit of Measure (UoM) Usage Matrix

Este repositorio contiene un *query* SQL (T-SQL/HANA/SQL de SAP) diseñado para generar una vista dinámica de todas las **Unidades de Medida Alternativas (UMA)** utilizadas por los materiales en el sistema SAP, mostrando su factor de conversión y su estado de activación en diferentes formatos de negocio (Base, Pedido, Entrada/Salida, Venta).

El *query* simula una **tabla pivote** para ofrecer una vista clara y matricial del *packaging* y las unidades de manejo de cada material.

---

## ✨ Características Principales

* **Matriz de Uso (Pivot):** Utiliza funciones de agregación (`MAX` con `CASE WHEN`) para crear columnas indicadoras (`1` o `0`) que muestran si una UMA específica se utiliza como Unidad Base, de Pedido, de Entrada/Salida (E/S) o de Venta.
* **Cálculo de Factor de Conversión:** Calcula con precisión el factor de conversión (`CANTIDAD`) a la Unidad Base, manejando casos complejos donde la unidad de referencia (`MESUB`) es otra unidad alternativa.
* **Estandarización de UoM:** Incluye lógica `CASE` para transformar y estandarizar códigos de unidad de medida (ej. `BAG` a `BOL`, `CS` a `CJ`) para asegurar la consistencia con los datos del sistema de destino.
* **Exclusión de Materiales:** Filtra y excluye materiales de tipos específicos.
* **Datos Clave:** Recupera el código EAN asociado a cada UMA.

---

## 🛠️ Estructura de Tablas SAP Utilizadas

| Alias | Tabla | Descripción |
| :--- | :--- | :--- |
| `mm` | `SAP_ECC.MARM` | Unidades de Medida Alternativas por Material. |
| `m` | `SAP_ECC.MARA` | Datos Generales del Maestro de Materiales (Unidad Base y de Pedido). |
| `mw` | `SAP_ECC.MAW1` | Datos de Unidad de Medida Específicos de Almacén (E/S y Venta). |

---

## 🔍 Columnas de Salida Clave

| Columna | Descripción | Origen del Dato / Lógica |
| :--- | :--- | :--- |
| **`MATERIAL`** | Número de identificación del material. | `MARM.MATNR` |
| **`UMA`** | Unidad de Medida Alternativa estandarizada. | `MARM.MEINH` (con transformación `CASE`) |
| **`CANTIDAD`** | Factor de conversión de la UMA a la Unidad Base del material. | Lógica de división que considera `MARM.UMREZ`, `MARM.UMREN` y `MARM.MESUB`. |
| **`UMB`** | Indicador (1/0) si la UMA es la **Unidad Base**. | `MEINH` comparada con `MARA.MEINS` |
| **`Ped`** | Indicador (1/0) si la UMA es la **Unidad de Pedido**. | `MEINH` comparada con `MARA.BSTME` |
| **`ES`** | Indicador (1/0) si la UMA es la **Unidad de Entrada/Salida**. | `MEINH` comparada con `MAW1.WAUSM` |
| **`UMV`** | Indicador (1/0) si la UMA es la **Unidad de Venta**. | `MEINH` comparada con `MAW1.WVRKM` |
| **`EAN`** | Código EAN asociado a la UMA. | `MARM.EAN11` |

---

## 📝 Documentación del Query

El archivo SQL incluye un bloque de documentación detallado que especifica el propósito, autor, fecha de creación, tablas utilizadas y notas importantes sobre la lógica de conversión y el cálculo de factores.

### Extracto del Propósito:

> **Propósito:** Mostrar las unidades de variación (alternativas) de los materiales en formato de matriz (pivote), donde '1' indica que la unidad de medida alternativa (UMA) está activa para un formato específico (Base, Pedido, E/S, Venta) y '0' indica que no. Esto proporciona una vista dinámica de las unidades de manejo de cada material, excluyendo materiales cuyo tipo ('MTART') comienza con 'Y'.

---

## 👤 Autor

**Leonardo Polanco**

* [[Tu Perfil de LinkedIn](https://www.linkedin.com/in/leonardo-polanco-navas/)] 

---
