#!/usr/bin/perl

use utf8;
use warnings;
use strict;

use Switch;
use LWP::Simple;
use HTML::TableExtract;
use WWW::Mechanize;

my $serie = 'http://www.ipeadata.gov.br/ExibeSerie.aspx?serid=38513&module=M';
my $html = get $serie;

# Escreve no LOG_Indicadores
  open( LOG, ">>../../../LOG_Indicadores" ) || die "problema ao abrir log\n";
  print LOG "\n\tInflação oficial (IPCA-IBGE, fonte: IPEADATA)";
  print LOG "\n\t\tlink utilizado: " . $serie;

if (getstore($serie, '../fonte/fonte_informacao_IPCA_IpeaData.html')) {
  print LOG "\n\t\tdownload do html: OK";
} else {
  print LOG "\n\t\tdownload do html: Falhou";
}

my $te = new HTML::TableExtract( keep_html=>0, depth => 1, count => 0 );
$te->parse($html);

my $sep = "|";  # separador
my $indice = "IPCA";
my @MATRIZ=();

foreach my $ts ($te->tables){
  foreach my $row ($ts->rows){

    if ($row->[1] =~ /\d+/) {

      my $data_dma =  $row->[0];
         $data_dma =~ s/\s+//g;
         $data_dma =~ s/\n|\r|\R|\r\n|&NBSP;//g;

      my $dia = '01';
      my $mes = substr($data_dma, 5, 2);
      my $ano = substr($data_dma, 0, 4);

      my $data = $ano . "-" . $mes . "-" . $dia;

      my $valor =  $row->[1];
         $valor =~ s/\s+//g;
         $valor =~ s/\n|\r|\R|\r\n|&NBSP;//g;

         $valor =~ s/\.//g;
         $valor =~ s/\,/\./g;

      push(@MATRIZ, $data . $sep . $indice . $sep . $valor/100 . "\n");
    }
  }
}

# Inflação ao mês, tal como está no site do IPEA-Data
# Exporta informações para arquivo 'ipca', pronto para ser importado ao SQLite
open( FILE, ">../ipca_mensal" ) || die "problema ao abrir ../ipca_mensal\n";
print FILE @MATRIZ;
close(FILE);

# Acumula o IPCA para os últimos 12 meses
for (my $a = $#MATRIZ; $a >= 11 ; $a-- ){
  # começa do último registro
  my $offset = 16; # o índice IPCA começa na posição 16  AAAA-MM-DD|IPCA|
  substr($MATRIZ[$a],$offset) = (1+substr($MATRIZ[$a    ],$offset,length($MATRIZ[$a    ])-17))*
                                (1+substr($MATRIZ[$a-1  ],$offset,length($MATRIZ[$a-1  ])-17))*
                                (1+substr($MATRIZ[$a-2  ],$offset,length($MATRIZ[$a-2  ])-17))*
                                (1+substr($MATRIZ[$a-3  ],$offset,length($MATRIZ[$a-3  ])-17))*
                                (1+substr($MATRIZ[$a-4  ],$offset,length($MATRIZ[$a-4  ])-17))*
                                (1+substr($MATRIZ[$a-5  ],$offset,length($MATRIZ[$a-5  ])-17))*
                                (1+substr($MATRIZ[$a-6  ],$offset,length($MATRIZ[$a-6  ])-17))*
                                (1+substr($MATRIZ[$a-7  ],$offset,length($MATRIZ[$a-7  ])-17))*
                                (1+substr($MATRIZ[$a-8  ],$offset,length($MATRIZ[$a-8  ])-17))*
                                (1+substr($MATRIZ[$a-9  ],$offset,length($MATRIZ[$a-9  ])-17))*
                                (1+substr($MATRIZ[$a-10 ],$offset,length($MATRIZ[$a-10 ])-17))*
                                (1+substr($MATRIZ[$a-11 ],$offset,length($MATRIZ[$a-12 ])-17))-1;
  substr($MATRIZ[$a],$offset) = sprintf "%.4f", substr($MATRIZ[$a],$offset); # arrendonda para 4 casas decimais
  $MATRIZ[$a] = $MATRIZ[$a] . "\n";
}
splice(@MATRIZ,0,11);

# Exporta informações para arquivo 'ipca', pronto para ser importado ao SQLite
my $saida = '../ipca';
open( FILE, ">$saida" ) || die "problema ao abrir $saida\n";
print FILE @MATRIZ;
close(FILE);

  print LOG "\n\t\tarquivo para importação no SQLite: OK (Indicadores/Inflação/ipca)";
  print LOG "\n\t\tprimeiras 3 linhas:";
  print LOG "\n\t\t\t".$MATRIZ[0];
  print LOG   "\t\t\t".$MATRIZ[1];
  print LOG   "\t\t\t".$MATRIZ[2];
  print LOG   "\t\túltimas 3 linhas:";
  print LOG "\n\t\t\t".$MATRIZ[$#MATRIZ-2];
  print LOG   "\t\t\t".$MATRIZ[$#MATRIZ-1];
  print LOG   "\t\t\t".$MATRIZ[$#MATRIZ  ];
close(LOG);

