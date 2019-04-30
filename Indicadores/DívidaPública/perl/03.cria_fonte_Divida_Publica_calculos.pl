#!/usr/bin/perl
use Switch;
use strict;
use warnings;
use utf8;
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::SaveParser;

# Abre fonte_divida_publica.xls existente com o SaveParser
my $parser   = Spreadsheet::ParseExcel::SaveParser->new();
my $template = $parser->Parse('../fonte/fonte_divida_publica.xls');

# Vai para a segunda aba, chama '% PIB'
my $worksheet = $template->worksheet(1);

# Variáveis globais que guardam o escopo da planilha
my ($row_min, $row_max) = $worksheet->row_range();
my ($col_min, $col_max) = $worksheet->col_range();

my $celula;

# $linha guarda o número da linha da 'Dívida Bruta do Governo Geral (B)'
my $linha;
for my $i (0 .. $row_max){
  $celula = $worksheet->get_cell( $i, 0)->value();
  if ($celula =~ m/geral \(B\)/) {
    $linha = $i;
    last;
  }
}

# Linha 3 e 4 guardarão os cálculos que serão exportados para o CSV
$worksheet->AddCell(  2-1, 0, 'Cálculos do Script Perl' );
 $worksheet->AddCell( 3-1, 0, 'Data (AAAA-MM-01) -->' );
 $worksheet->AddCell( 4-1, 0, 'Taxa -->' );

my @Divida_Publica = ();

# Leitura da série da dívida bruta do governo geral em % do PIB
my $taxa;
my $ano;
my $mes_dia;

for my $coluna (2 .. $col_max){   # 2 porque a série começa na coluna C - terceira coluna, ou 3-1 no perl
 # Tratamento da Data: une $ano ao $mes_dia, cujo formato é -MM-01
  # $ano
    $celula =  $worksheet->get_cell( 5-1, $coluna )->value();
    if ( $celula =~ m/\d/ ){
      $ano = $celula;
    }

  # $mes_dia
    $celula =  $worksheet->get_cell( 7-1, $coluna )->value();
    $celula =~ s/\s+//g;
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
    $worksheet->AddCell( 3-1, $coluna, $ano . $mes_dia );

  # $taxa
    $taxa =  $worksheet->get_cell( $linha, $coluna )->value();
    $taxa =~ s/\,/\./g;
    $taxa = $taxa / 100;
    $worksheet->AddCell( 4-1, $coluna, $taxa );

 # Preenche array @Divida_Publica
  push( @Divida_Publica, $ano . $mes_dia . '|' . 'Divida_Publica_Perc_PIB' . '|' . $taxa . "\n" );

}

# Escreve no LOG_Indicadores
  open( LOG, ">>../../../LOG_Indicadores" ) || die "problema ao abrir log\n";

if ($template->SaveAs('../fonte/fonte_divida_publica_calculos.xls')){
  print LOG "\n\t\tcálculos no excel: OK";
} else {
  print LOG "\n\t\tcálculos no excel: Falhou";
}


# Exporta informações para arquivo 'pme', pronto para ser importado ao SQLite
my $saida = '../divida_publica';
open( FILE, ">$saida" ) || die "problema ao abrir $saida\n";
print FILE @Divida_Publica;
close(FILE);

# Escreve no LOG_Indicadores
  print LOG "\n\t\tarquivo para importação no SQLite: OK (Indicadores/DívidaPública/divida_publica)";
  print LOG "\n\t\tprimeiras 3 linhas:";
  print LOG "\n\t\t\t".$Divida_Publica[0];
  print LOG   "\t\t\t".$Divida_Publica[1];
  print LOG   "\t\t\t".$Divida_Publica[2];
  print LOG   "\t\túltimas 3 linhas:";
  print LOG "\n\t\t\t".$Divida_Publica[$#Divida_Publica-2];
  print LOG   "\t\t\t".$Divida_Publica[$#Divida_Publica-1];
  print LOG   "\t\t\t".$Divida_Publica[$#Divida_Publica  ];
close(LOG);
