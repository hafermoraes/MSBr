#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use WWW::Mechanize;
use LWP::Simple;

my $link = 'http://www.bcb.gov.br/Pec/metas/TabelaMetaseResultados.pdf';

my $mech = WWW::Mechanize->new();
$mech->get( $link );

getstore( $link, '../../../Relatorio/img/BacenHistoricoMetas.pdf');


