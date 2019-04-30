#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use Encode;
use open ':locale';
binmode STDOUT, ':encoding(utf-8)';

use HTML::TableExtract;

# Escreve no LOG_BaseANS
open( LOG, ">>../../LOG_BaseANS" ) || die "problema ao abrir log\n";
print LOG "\n\tANS - Receitas, Despesas Administrativas e Despesas Assistenciais";

# 'ANS_Mercado_Supervisionado' guardará a lista de todo o mercado supervisionado,
# pronta para ser importada ao R para ser trabalhada pelo pacote reshape
my $output = '../ANS_Mercado_Supervisionado';
open( FILE, ">$output" ) || die "problema ao abrir $output\n";
  print FILE 'Tipo_Operadora|Info_Financeira|Operadora|';
  print FILE '2001|2002|2003|2004|2005|2006|2007|2008|2009|2010|2011|2012|2013|2014';

  print LOG "\n\t\tInclusão da linha com o título no arquivo BaseANS/ANS_Mercado_Supervisionado: ok";
#close(FILE);

# cria o navegador
use WWW::Mechanize;
my $browser = WWW::Mechanize->new();

# acessa a página do Tab-Net com o navegador
my $url = "http://www.ans.gov.br/anstabnet/cgi-bin/dh?dados/tabnet_rc.def";
$browser->get($url);

  print LOG "\n\t\tAcesso ao site " . $url .":\tok";

# variáveis da consulta no site da ANS
my @var_incremento = (
                      "Receita",
                      "Desp.Administrativa",
                      "Desp.Assistencial"
                     );
my %var_modalidade = ( # Tipos de operadora.
                      "1" => 'Autogestão'                        ,
                      "2" => 'Cooperativa Médica'                ,
                      "3" => 'Filantropia'                       ,
                      "4" => 'Medicina de Grupo'                 ,
                      "5" => 'Seguradora Especializada em Saúde' ,
                      "6" => 'Cooperativa Odontológica'          ,
                      "7" => 'Odontologia de Grupo'              ,
                     );

foreach my $tipo_empresa (keys %var_modalidade )  # Para cada tipo de operadora em %var_modalidade
{

  print LOG "\n\t\t" . $var_modalidade{$tipo_empresa};

  foreach my $incremento ( @var_incremento ){ # para cada tipo de informação financeira, faça

   print LOG "\n\t\t\t" . $incremento;

   $browser->get($url); # acessa o site inicial do Tab-Net
   $browser->submit_form( # preenche o formulário web conforme opções abaixo
    form_number => 1, # acessa o primeiro formulário encontrado
    fields =>
    { #preeenche os campos do formulário de acordo com as opções abaixo
      Linha       => 'Operadora',
      Coluna      => 'Ano',
      Incremento  => $incremento, # este controla a informação financeira a ser gerada: receita, desp. admin., etc...
      Arquivos    => [
                        [
                         'tb_rc_14.dbf', # notação estranha da ANS, mas significa o ano de 2014
                         'tb_rc_13.dbf', # ano de 2013, etc...
                         'tb_rc_12.dbf',
                         'tb_rc_11.dbf',
                         'tb_rc_10.dbf',
                         'tb_rc_09.dbf',
                         'tb_rc_08.dbf',
                         'tb_rc_07.dbf',
                         'tb_rc_06.dbf',
                         'tb_rc_05.dbf',
                         'tb_rc_04.dbf',
                         'tb_rc_03.dbf',
                         'tb_rc_02.dbf',
                         'tb_rc_01.dbf',
                        ],1
                     ],
      SModalidade => $tipo_empresa,
      SOperadora  => 'TODAS_AS_CATEGORIAS__', # lista todas as operadoras na primeira coluna
      formato     => 'prn', # marca a opção 'Colunas separadas por ";"'
    }
    , button => 'mostre' # após preencher formulário, clica no botão 'Mostra' e vai para a próxima página
  );

  # salva página na pasta ../CSVs
  $browser->save_content('../fonte/'.$var_modalidade{$tipo_empresa}.'_'.$incremento.'.html');
  print LOG "\n\t\t\t\tCópia do original do site ANS na pasta BaseANS/fonte/:\tok";


      # Código para salvar arquivos CSV do site da ANS via TabNet
      #  my @links = $browser->links();  # guarda no array @links todos os links da página gerada
      #  for my $link ( @links )  # para cada link no vetor,
      #  {
      #    if ( $link->text =~ /\.CSV/ ) # procura o que contém, na descrição do link, o padrão '.CSV'
      #    {
      #      $browser->get(
      #                    $link->url_abs,
      #                    ':content_file' => '../CSVs/'.$var_modalidade{$tipo_empresa}.'_'.$incremento.'.csv'
      #                   ); # e salva o arquivo CSV na pasta ../CSVs/
      #    }
      #  }

    my @auxiliar = split /\n/, $browser->content(); # salva página com resultado na array @auxiliar
    for (@auxiliar) { # roda linha por linha

      decode('UTF-8', $_);

      s/"//g; # substitui aspas duplas (") por vazio
      # Corrige a acentuação
        s/&Aacute;/Á/g;
        s/&Eacute;/É/g;
        s/&Iacute;/Í/g;
        s/&Oacute;/Ó/g;
        s/&Uacute;/Ú/g;
        s/&Atilde;/Ã/g;
        s/&Otilde;/Õ/g;
        s/&Ccedil;/Ç/g;
        s/&Acirc;/Â/g;
        s/&Ecirc;/Ê/g;
        s/&Ocirc;/Ô/g;
        s/&Agrave;/À/g;

      s/;/|/g; # e substitui ; por |

      if ($_ =~ m/^\d+/g) { # se linha começa com mais de um dígito, entra no if
          # escreve no arquivo ANS_Mercado_Supervisionado
        print FILE "\n" . $var_modalidade{$tipo_empresa} . '|' . $incremento .'|' . $_;
      }
    }
    print LOG "\n\t\t\t\tInclusão da tabela tratada ANS_Mercado_Supervisionado:\tok";
  }
}
close (FILE);

