Relatorio_PDF:
	cd Relatorio; \
	make

# Variáveis
DIR_Susep = BaseSES_SUSEP/fonte/CSVs

# ----------------------------------------------------------------------------------------
# Base ANS do site - http://www.ans.gov.br/anstabnet/cgi-bin/dh?dados/tabnet_rc.def
# ----------------------------------------------------------------------------------------
BaseANS_Baixa:
	printf 'Base ANS'                                                      > LOG_BaseANS
	printf '\n\tExecução do script BaseANS/perl/ANS.Baixa_CSVs.pl...'     >> LOG_BaseANS
	cd BaseANS/perl;         perl    ANS.Baixa_CSVs.pl
	cd BaseANS/R;            Rscript ANS.R
	printf '\n\tPreparação dos CSVs para importar na base SQLIte: ok'     >> LOG_BaseANS
	clear

BaseANS_Exporta_SQLite:
	cat Scripts/BaseDeDados/MSBr-Importa-BaseANS.sql | sqlite3 -separator '|' MSBr.db
	printf '\n\tImportação dos CSVs para na base SQLIte MSBr.db: ok'      >> LOG_BaseANS

# ----------------------------------------------------------------------------------------
# Base SES do site da SUSEP - http://www2.susep.gov.br/menuestatistica/SES/principal.aspx
# ----------------------------------------------------------------------------------------
BaseSES_Baixa:
	printf 'Base SES/SUSEP'                                                > LOG_BaseSES
	cd BaseSES_SUSEP/perl;                  \
		perl 01.download_base_ses_susep.pl;   \
		perl 02.descompacta_zip_base_ses_susep.pl
	printf '\n\t Prepara CSVs para importar na base SQLIte...'            >> LOG_BaseSES
	printf '\n\t Substitui virgula (,) pelo ponto (.) em cada arquivo'    >> LOG_BaseSES
	printf '\n\t Troca de nome dos arquivos para minusculas somente'      >> LOG_BaseSES
	cd $(DIR_Susep);                        \
	sed -i 's/,/./g' *.csv;                 \
	for i in $( ls | grep [A-Z] ); do mv $i `echo $i | tr 'A-Z' 'a-z'`; done
	clear

#	rename -f 'y/A-Z/a-z/' *.csv

BaseSES_Exporta_SQLite:
	cat Scripts/BaseDeDados/MSBr-Importa-BaseSES.sql | sqlite3 -separator ';' MSBr.db
	printf '\n\t Importação dos CSVs para na base SQLIte MSBr.db: ok'     >> LOG_BaseSES

BaseSES_Limpa:
	cd $(DIR_Susep); rm *.csv; \
	cd ..; rm *.zip;

# ----------------------------------------------------------------------------------------
# Indicadores
# ----------------------------------------------------------------------------------------
Indicadores_Baixa:
	printf 'INDICADORES\n'        >         LOG_Indicadores ;
	cd Indicadores/Bovespa/R;               Rscript IBovespa.R
	cd Indicadores/Câmbio/R;                Rscript cambio.R
	cd Indicadores/Desemprego/perl;         perl    01.download_PME.pl ;                    \
		                                      perl    02.cria_fonte_PME_calculos.pl
	cd Indicadores/DívidaPública/perl;      perl    01.download_divida.pl ;                 \
		                                      perl    02.descompacta_zip_divida_publica.pl ;  \
		                                      perl    03.cria_fonte_Divida_Publica_calculos.pl
	cd Indicadores/EMBI/perl;               perl    EMBI.pl
	cd Indicadores/Inflação/perl/;          perl    IPCA.pl ;                               \
		                                      perl    IPCA_por_Grupo.pl ;                     \
		                                      perl    bcb_metas_inflacao.pl
	cd Indicadores/Juros/perl/;             perl    SELIC.pl
	cd Indicadores/PIB/perl/;               perl    PIB.pl
	cd Indicadores/Rating/perl/;            perl    Rating.pl
	cd Indicadores/ReservasUSD/perl;        perl    ReservasUSD.pl
	cd Indicadores/SUSEP/perl/;             perl    SUSEP_Mercado_Supervisionado.pl
	clear

Indicadores_Graficos:
	cd Indicadores/Desemprego/R;            Rscript PME.R
	cd Indicadores/DívidaPública/R;         Rscript DívidaPública.R
	cd Indicadores/EMBI/R;                  Rscript EMBI.R
	cd Indicadores/Inflação/R/;             Rscript IPCA.R ;                                \
		                                      Rscript IPCA_por_Grupo.R
	cd Indicadores/Juros/R/;                Rscript SELIC.R
	cd Indicadores/PIB/R/;                  Rscript PIB.R
	cd Indicadores/ReservasUSD/R;           Rscript ReservasUSD.R
	printf '\n\t Gráficos atualizados no diretório Relatorio/img: ok'       >> LOG_Indicadores
	cat Scripts/BaseDeDados/MSBr-Importa-Indicadores.sql | sqlite3 -separator '|' MSBr.db
	printf '\n\t Importação dos Indicadores na base SQLIte MSBr.db: ok'     >> LOG_Indicadores
	clear

# ----------------------------------------------------------------------------------------
# Criação da tabela MSBr (após BaseANS, BaseSES e Indicadores estarem OK
# ----------------------------------------------------------------------------------------
Base_MSBr:
	cat Scripts/BaseDeDados/MSBr-Tabela-MSBr.sql    | sqlite3 -separator '|' MSBr.db

# ----------------------------------------------------------------------------------------
# Análises
# ----------------------------------------------------------------------------------------
# Dado que Base_SES, Base_ANS e Indicadores estão atualizados, rodar análises do R
Tabelas:
	cat Scripts/BaseDeDados/100.Mercado.Seguros.sql | sqlite3 -separator ';' -header MSBr.db > Relatorio/tabelas/Seguros
	cd Scripts/R;                                        \
	              rm        *.RData ;                    \
	              Rscript   P01.ContextoMacro.R ;        \
	              Rscript   P02.MercadoSeguros.R


