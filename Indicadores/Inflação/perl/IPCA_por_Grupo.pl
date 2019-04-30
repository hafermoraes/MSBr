#!/usr/bin/perl

use utf8;
use warnings;
use strict;

use Switch;
use LWP::Simple;
use HTML::TableExtract;
use WWW::Mechanize;

# Lista dos links por grupo de gastos do IPCA
my %grupo = (
             'http://www.ipeadata.gov.br/ExibeSerie.aspx?serid=39861&module=M' => 'Alimentação e Bebidas',
             'http://www.ipeadata.gov.br/ExibeSerie.aspx?serid=39862&module=M' => 'Artigos de Residência',
             'http://www.ipeadata.gov.br/ExibeSerie.aspx?serid=39863&module=M' => 'Despesas Pessoais',
             'http://www.ipeadata.gov.br/ExibeSerie.aspx?serid=39864&module=M' => 'Comunicação',
             'http://www.ipeadata.gov.br/ExibeSerie.aspx?serid=39865&module=M' => 'Educação',
             'http://www.ipeadata.gov.br/ExibeSerie.aspx?serid=39866&module=M' => 'Habitação',
             'http://www.ipeadata.gov.br/ExibeSerie.aspx?serid=39867&module=M' => 'Saúde e Cuidados Pessoais',
             'http://www.ipeadata.gov.br/ExibeSerie.aspx?serid=39868&module=M' => 'Transportes',
             'http://www.ipeadata.gov.br/ExibeSerie.aspx?serid=39869&module=M' => 'Vestuário'
            );

foreach my $serie (keys %grupo){

    # Entra no site do IPEA-Data e baixa página presente na hash %grupo
    my $html = get $serie;
    my $te = new HTML::TableExtract( keep_html=>0, depth => 1, count => 0 );
    $te->parse($html);

    my $sep = "|";  # separador
    my $indice = $grupo{ $serie };
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

    # Exporta informações para arquivo 'ipca_mensal', pronto para ser importado ao SQLite
    open( FILE, ">>../ipca_mensal" ) || die "problema ao abrir ../ipca_mensal\n";
    print FILE @MATRIZ;
    close(FILE);
}
