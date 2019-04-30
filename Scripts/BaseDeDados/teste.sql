
SELECT
    i.Mes
  , i.Indice
  , sum(i.Valor)
FROM
  Indices i
WHERE
  strftime('%Y', i.Mes) = strftime('%Y',(SELECT max(Mes) FROM Indices WHERE Indice = 'PIB'))
AND
  i.Indice = 'PIB'
