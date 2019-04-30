#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use Switch;
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::SaveParser;

# Exporta informações para arquivo LOG_Indicadores
  open(LOG, ">>../../../LOG_Indicadores" ) || die print LOG "\n\t\tProblema ao abrir LOG";

# Abre fonte_PME.xls existente com o SaveParser
my $parser   = Spreadsheet::ParseExcel::SaveParser->new();
my $template = $parser->Parse('../fonte/fonte_PME.xls');
# Vai para a primeira aba, chamada 'tab 177'
my $worksheet = $template->worksheet(0);
# $inicio guarda número da linha que contém 'Estimativas (%)
my $inicio = 0;
# $inicio guarda número da linha que contém 'Coeficientes de Variação (%)'
my $fim    = 0;
# Preenche primeiro as variáveis $inicio e $fim
my $linha = 0;
my $celula;
my ($min, $max) = $worksheet->row_range();
for $linha ($min .. $max-1){
  $celula = $worksheet->get_cell( $linha, 0 )->value();
  if ($celula =~ m/stimativ/) {
    $inicio = $linha + 1;
  }
  if ($celula =~ m/oeficient/) {
    $fim = $linha - 2;
    last;
  }
}

# Colunas J a M guardarão os cálculos que serão exportados para o CSV
$worksheet->AddCell( 6 - 1, 10 - 1, 'Cálculos do Script Perl' );
 $worksheet->AddCell( 7 - 1, 10 - 1, "Linha do 'Estimativas (%)':" );
  $worksheet->AddCell( 7 - 1, 11 - 1, $inicio + 1 );
 $worksheet->AddCell( 8 - 1, 10 - 1, "Linha do 'Coeficientes de variação (%):" );
  $worksheet->AddCell( 8 - 1, 11 - 1, $fim + 1 );

$worksheet->AddCell( 10 -1, 10 - 1, 'AAAA-MM-DD' );
$worksheet->AddCell( 10 -1, 11 - 1, 'Taxa' );

my $ano;
my $mes_dia;
my @PME = ();
for $linha ($inicio .. $fim){
  $celula =  $worksheet->get_cell($linha,0)->value();
  $celula =~ s/\s+//g;  # retira espaço vazio da célula
  # Se conteúdo é numérico, então guarda o conteúdo na variável $ano
  if ($celula =~ m/\d/){
    $ano = $celula;
    next;
  } else {
    # Tratamento da Data: substitui 'jan' por '-01-01' e assim por diante
        switch (lc(substr($celula,0,3))){
          case 'jan' { $mes_dia = '-01-01'}
          case 'fev' { $mes_dia = '-02-01'}
          case 'mar' { $mes_dia = '-03-01'}
          case 'abr' { $mes_dia = '-04-01'}
          case 'mai' { $mes_dia = '-05-01'}
          case 'jun' { $mes_dia = '-06-01'}
          case 'jul' { $mes_dia = '-07-01'}
          case 'ago' { $mes_dia = '-08-01'}
          case 'set' { $mes_dia = '-09-01'}
          case 'out' { $mes_dia = '-10-01'}
          case 'nov' { $mes_dia = '-11-01'}
          case 'dez' { $mes_dia = '-12-01'}
        }
    # Tratamento da Taxa
      my $taxa =  $worksheet->get_cell($linha,1)->value();
         $taxa =~ s/\,/\./g;
         $taxa =  $taxa / 100;
    # Preenche excel com valores
         $worksheet->AddCell( $linha, 10-1, $ano . $mes_dia );
         $worksheet->AddCell( $linha, 11-1, $taxa );
    # Preenche array @PME
      push( @PME, $ano . $mes_dia . '|' . 'PME' . '|' . $taxa . "\n");
  }
}

if ($template->SaveAs('../fonte/fonte_PME_calculos.xls')){
  print LOG "\n\t\tcálculos no excel: OK";
} else {
  print LOG "\n\t\tcálculos no excel: Falhou";
}

# Exporta informações para arquivo 'pme', pronto para ser importado ao SQLite
my $saida = '../pme';
open( FILE, ">$saida" ) || die "problema ao abrir $saida\n";
print FILE @PME;
close(FILE);

  print LOG "\n\t\tarquivo para importação no SQLite: OK (Indicadores/Desemprego/pme)";
  print LOG "\n\t\tprimeiras 3 linhas:";
  print LOG "\n\t\t\t ".$PME[0];
  print LOG   "\t\t\t ".$PME[1];
  print LOG   "\t\t\t ".$PME[2];
  print LOG   "\t\túltimas 3 linhas:";
  print LOG "\n\t\t\t ".$PME[$#PME-2];
  print LOG   "\t\t\t ".$PME[$#PME-1];
  print LOG   "\t\t\t ".$PME[$#PME  ];

close(LOG);
