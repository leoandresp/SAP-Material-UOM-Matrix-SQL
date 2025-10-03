/*
 * Propósito: Mostrar las unidades de variación (alternativas) de los materiales
 * en formato de matriz (pivote), donde '1' indica que la unidad de
 * medida alternativa (UMA) está activa para un formato específico
 * (Base, Pedido, E/S, Venta) y '0' indica que no. Esto proporciona una
 * vista dinámica de las unidades de manejo de cada material,
 * excluyendo materiales cuyo tipo ('MTART') comienza con 'Y'.
 *
 * Autor: Leonardo Polanco
 * Fecha de Creación: 21 de agosto de 2025
 * Última Modificación: 21 de agosto de 2025
 *
 * Tablas:
 * "SAP_ECC"."MARM" (mm): Unidades de Medida Alternativas por Material.
 * "SAP_ECC"."MARA" (m): Datos Generales del Maestro de Materiales (Unidad Base y de Pedido).
 * "SAP_ECC"."MAW1" (mw): Datos de Unidad de Medida Específicos para Almacén (E/S y Venta).
 *
 * Notas Importantes:
 * - Se aplica lógica de conversión manual de códigos de unidad de medida para
 * estandarizar a las unidades utilizadas en el sistema SAP de destino (ej. 'BAG' a 'BOL').
 * - El cálculo de "CANTIDAD" maneja casos donde la unidad de referencia
 * ("MESUB") es otra unidad de medida alternativa, requiriendo una subconsulta
 * para obtener el factor de conversión correcto de esa unidad de referencia.
 *
 *******************************************************************************
*/
SELECT
    mm."MATNR" AS "MATERIAL",
    --Transformación del dato para que concuerde con las unidades de SAP
    CASE WHEN mm."MEINH" = 'BAG' THEN 'BOL'
    	 WHEN mm."MEINH" = 'CS' THEN 'CJ'
    	 WHEN mm."MEINH" = 'DZ' THEN 'DOC'
    	 WHEN mm."MEINH" = 'GLL' THEN 'GAL'
    	 WHEN mm."MEINH" = 'KAR' THEN 'CAR'
    	 WHEN mm."MEINH" = 'KI' THEN 'CA'
    	 WHEN mm."MEINH" = 'PAK' THEN 'BTO'
    	 WHEN mm."MEINH" = 'ST' THEN 'UN' ELSE mm."MEINH" END AS "UMA", -- Unidad de Medida Alternativa estandarizada
 
 	-- Si la unidad de referencia (MESUB) es otra unidad de medida alternativa, se divide entre la cantidad de la otra medida alternativa.
 	CASE WHEN mm."MESUB" = '' -- Si MESUB está vacío, usa el factor de conversión estándar (UMREZ/UMREN)
 		 THEN mm."UMREZ" / NULLIF(mm."UMREN", 0)
 		 ELSE mm."UMREZ" /NULLIF((SELECT "UMREZ" FROM "SAP_ECC"."MARM" mmsb -- Si MESUB no está vacío, busca su factor de conversión
 		 	 	 	 	 	  WHERE mm."MATNR" = mmsb."MATNR" AND mmsb."MEINH" = mm."MESUB"),0)
 		 END AS "CANTIDAD", -- Factor de conversión a la unidad base
 
    -- Compara la UMA (MEINH) con la Unidad Base (MEINS) para la matriz UMB
    MAX(CASE WHEN mm."MEINH" = m."MEINS" THEN 1 ELSE 0 END) AS "UMB",  
      
   -- En caso que el valor de Ped. (BSTME) este vacio, se coloca el mismo valor de unidad Base
	CASE WHEN m."BSTME" <> '' -- Si la Unidad de Pedido existe
    	THEN (CASE WHEN mm."MEINH" = m."BSTME" THEN 1 ELSE 0 END)
    	ELSE (CASE WHEN mm."MEINH" = m."MEINS" THEN 1 ELSE 0 END) END AS "Ped", -- Matriz para Unidad de Pedido
    
    -- En caso que el valor de "E/S" (WAUSM) este vacio, se coloca el mismo valor de unidad Base	
   CASE WHEN mw."WAUSM" <> '' -- Si la Unidad de Entrada/Salida existe
    THEN (CASE WHEN mm."MEINH" = mw."WAUSM" THEN 1 ELSE 0 END)
    ELSE (CASE WHEN mm."MEINH" = m."MEINS" THEN 1 ELSE 0 END) END AS "ES", -- Matriz para Unidad de Entrada/Salida
	
    -- En caso que el valor de "UMV" (WVRKM) este vacio, se coloca el mismo valor de unidad Base
    CASE WHEN mw."WVRKM" <> '' -- Si la Unidad de Venta existe
    THEN (CASE WHEN mm."MEINH" = mw."WVRKM" THEN 1 ELSE 0 END)
    ELSE (CASE WHEN mm."MEINH" = m."MEINS" THEN 1 ELSE 0 END) END AS "UMV", -- Matriz para Unidad de Venta
    
    mm."EAN11" AS EAN -- Código EAN asociado a la UMA
    
FROM "SAP_ECC"."MARM" mm -- Tabla de Unidades de Medida Alternativas

LEFT JOIN "SAP_ECC"."MARA" m ON mm."MATNR" = m."MATNR" -- Une datos generales del material
LEFT JOIN "SAP_ECC"."MAW1" mw ON mm."MATNR" = mw."MATNR" -- Une datos de unidades de almacén

WHERE m."MTART" NOT LIKE 'Y%' -- Excluimos el tipo de Material que empieza por 'Y'
    
GROUP BY -- Agrupación necesaria para la función de agregación MAX (simulando un PIVOT)
    mm."MATNR",
    m."MEINS",
    mm."MEINH",
    mm."UMREZ",
    mm."UMREN",
    mm."EAN11",
    m."BSTME",
    mm."MESUB",
    mw."WAUSM",
    mw."WVRKM"
 

 ORDER BY 1 -- Ordena por Material
