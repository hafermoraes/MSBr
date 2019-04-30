#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use Switch;
use LWP::Simple;
use HTML::TableExtract;
use LWP::Simple;

my $rating = 'http://countryeconomy.com/ratings/brazil';
my $html = get $rating;

# Escreve no LOG_Indicadores
  open( LOG, ">>../../../LOG_Indicadores" ) || die "problema ao abrir log\n";
  print LOG "\n\tRatings";
  print LOG "\n\t\tlink utilizado: " . $rating;


if (getstore($rating, '../fonte/fonte_informacao_ratings.html')) {
  print LOG "\n\t\tdownload do html: OK";
} else {
  print LOG "\n\t\tdownload do html: Falhou";
}

my $agencia;# = $ARGV[0]; #"Moody's";

my @RATINGS;

$agencia="Moody's";
baixa_rating($agencia);
  print LOG "\n\t\tRating da Moody's: OK";

$agencia="S&P";
baixa_rating($agencia);
  print LOG "\n\t\tRating da S&P: OK";

$agencia="Fitch";
baixa_rating($agencia);
  print LOG "\n\t\tRating da Fitch: OK";


sub baixa_rating {
  my $te = new HTML::TableExtract( depth => 0, count => Agencia($_[0]) );
  $te->parse($html);

  my $sep = "|";  # separador
  my $indice = "Rating_" . $_[0];

  foreach my $ts ($te->tables){
    foreach my $row ($ts->rows){
      if ( ($row->[0] =~ /\d/ ) || ($row->[0] =~ /Date/) ) {   # primeira coluna, que contém data
        my $data = $row->[0];
        my $valor = $row->[1];
        if ($data =~ m/\d/){
          push(@RATINGS, $data . $sep . $indice . $sep . $valor . "\n");
        }
      }
    }
  }
}


# Exporta informações para arquivo 'ratings', pronto para ser importado ao SQLite
my $saida = '../ratings';
open( FILE, ">$saida" ) || die "problema ao abrir $saida\n";
print FILE @RATINGS;
close(FILE);


  print LOG "\n\t\tarquivo para importação no SQLite: OK (Indicadores/Rating/ratings)";
  print LOG "\n\t\tprimeiras 3 linhas:";
  print LOG "\n\t\t\t".$RATINGS[0];
  print LOG   "\t\t\t".$RATINGS[1];
  print LOG   "\t\t\t".$RATINGS[2];
  print LOG   "\t\túltimas 3 linhas:";
  print LOG "\n\t\t\t".$RATINGS[$#RATINGS-2];
  print LOG   "\t\t\t".$RATINGS[$#RATINGS-1];
  print LOG   "\t\t\t".$RATINGS[$#RATINGS  ];
close(LOG);

#--------------
# Funções
sub Agencia {
  switch($_[0]){
                   case "Moody's" { return 0 }
                   case "S&P"     { return 1 }
                   case "Fitch"   { return 2 }
  }
}
