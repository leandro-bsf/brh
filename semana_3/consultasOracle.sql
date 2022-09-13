/*Filtrar dependentes*/

select c.nome as colaborador , d.nome as dependente , d.data_nascimento
from  brh.dependente d
inner join  brh.colaborador c
on c.matricula = d.colaborador
where  upper(d.nome) like '%H%' or to_char( d.data_nascimento,'MM') in ('04','05','06') 
order by c.nome , d.nome

/*Listar colaborador com maior salário*/
select nome , salario from brh.colaborador
where  salario in (
select  max(salario)
from brh.colaborador )

/*Relatório de senioridade*/

select nome , salario,
(case
    when  salario < 3000 then 'JUNIOR'
    WHEN SALARIO > 3001 AND SALARIO <= 6000 THEN 'PLENO'
    WHEN SALARIO > 6001 AND SALARIO <= 20000 THEN 'SENIOR'
    WHEN SALARIO  > 20000 THEN 'CORPO DIRETOR'
    END) SENIORDIDADE

    FROM BRH.COLABORADOR
    ORDER BY SENIORDIDADE, NOME  
    
    
/*Listar colaboradores em projetos*/


SELECT D.NOME AS DEPARTAMENTO,P.NOME AS PROJETO, COUNT(*) AS QUANTIDADE
FROM  BRH.COLABORADOR C
INNER JOIN BRH.DEPARTAMENTO D 
ON  C.DEPARTAMENTO = D.SIGLA
INNER JOIN BRH.ATRIBUICAO A
ON  A.COLABORADOR = C.MATRICULA
INNER JOIN BRH.PROJETO P
ON P.ID =  A.PROJETO
GROUP BY D.NOME , P.NOME
ORDER BY D.NOME , P.NOME;

/*Listar colaboradores com mais dependentes*/

SELECT  C.NOME , D.COLABORADOR, COUNT(*) AS QUANTIDADE_DE_DEPENDENTES
FROM BRH.COLABORADOR C 
INNER JOIN BRH.DEPENDENTE D
ON  D.COLABORADOR = C.MATRICULA
GROUP BY C.NOME , D.COLABORADOR
HAVING COUNT(*) >= 2 
ORDER BY  QUANTIDADE_DE_DEPENDENTES DESC ,  C.NOME

/*Listar faixa etária dos dependentes*/

select colaborador, cpf, nome, parentesco,
    nvl(floor ((months_between(sysdate, data_nascimento)/12)),0) idade,
    case
    when nvl(floor(( months_between(sysdate ,  data_nascimento)/12)),0) < 18 
    then 'menor de idade'
    else
    'maior de idade'
    end faixa_etaria
from brh.dependente
order by colaborador, nome



/*Analisar necessidade de criar view*/

create or replace view vw_colaboradore_por_projeto as

SELECT D.NOME AS DEPARTAMENTO,P.NOME AS PROJETO, COUNT(*) AS QUANTIDADE
FROM  BRH.COLABORADOR C
INNER JOIN BRH.DEPARTAMENTO D 
ON  C.DEPARTAMENTO = D.SIGLA
INNER JOIN BRH.ATRIBUICAO A
ON  A.COLABORADOR = C.MATRICULA
INNER JOIN BRH.PROJETO P
ON P.ID =  A.PROJETO
GROUP BY D.NOME , P.NOME
ORDER BY D.NOME , P.NOME;

/*WV_FAIXA_ETÁRIA_DEPENDENTES*/
  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "SYSTEM"."WV_FAIXA_ETÁRIA_DEPENDENTES" ("COLABORADOR", "CPF", "NOME", "PARENTESCO", "IDADE", "FAIXA_ETARIA") AS 
  select colaborador, cpf, nome, parentesco,
    nvl(floor ((months_between(sysdate, data_nascimento)/12)),0) idade,
    case
    when nvl(floor(( months_between(sysdate ,  data_nascimento)/12)),0) < 18 
    then 'meno de idade'
    else
    'maior de idade'
    end faixa_etaria
from brh.dependente
order by colaborador, nome;
/*Relatório de senioridade_view*/

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "SYSTEM"."WV_RELATORIOS_SENIORIDADE" ("MATRICULA", "NOME", "SALARIO", "SENIORDIDADE") AS 
  select MATRICULA, nome , salario,
(case
    when  salario < 3000 then 'JUNIOR'
    WHEN SALARIO > 3001 AND SALARIO <= 6000 THEN 'PLENO'
    WHEN SALARIO > 6001 AND SALARIO <= 20000 THEN 'SENIOR'
    WHEN SALARIO  > 20000 THEN 'CORPO DIRETOR'
    END) SENIORDIDADE

    FROM BRH.COLABORADOR
    ORDER BY SENIORDIDADE, NOME;




/*Relatório de plano de saúde*/



SELECT  colaborador ,sum(VALOR) as total from (
     SELECT F.COLABORADOR , 100 AS  VALOR
   FROM wv_faixa_etária_dependenteS F
   WHERE F.PARENTESCO = 'CÃ´njuge'
   UNION
     SELECT F.COLABORADOR, 50 AS VALOR
   FROM   wv_faixa_etária_dependenteS F
   WHERE F.PARENTESCO = 'Filho(a)' AND F.FAIXA_ETARIA = 'maior de idade'
   UNION ALL
     SELECT F.COLABORADOR, 25 AS VALOR
   FROM wv_faixa_etária_dependenteS F
   WHERE F.PARENTESCO =  'Filho(a)' AND F.FAIXA_ETARIA = 'meno de idade'
   UNION ALL
    select 
    D.MATRICULA,
    case
          when D.SALARIO <= 3000  then D.SALARIO * 0.01
          when D.SALARIO <= 6000  THEN D.SALARIO * 0.02
          when D.SALARIO <= 20000 THEN D.SALARIO * 0.03
          WHEN D.SALARIO  >20000 THEN D.SALARIO * 0.05
    end as VALOR
from BRH.COLABORADOR D
)
GROUP BY COLABORADOR
ORDER BY COLABORADOR;
