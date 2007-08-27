package LimitCategory;
### LimitCategory - Limit the category that each user can post the entry on.
###         Programmed by Piroli YUKARINOMIYA (Open MagicVox.net)

use strict;
use MT::PluginData;
use MT::I18N;

use Exporter;
@LimitCategory::ISA = qw( Exporter );
use vars qw( @EXPORT_OK );
@EXPORT_OK = qw( save_plugindata load_plugindata set_lexicons );

########################################################################

sub load_plugindata {
    my ($key) = @_;
    my $plugindata = MT::PluginData->load ({ plugin => __PACKAGE__, key => $key })
        or return undef;
    $plugindata->data;
}

sub save_plugindata {
    my ($key, $data) = @_;
    my $plugindata = MT::PluginData->load ({ plugin => __PACKAGE__, key => $key });
    if (! $plugindata) {
        $plugindata = MT::PluginData->new;
        $plugindata->plugin (__PACKAGE__);
        $plugindata->key ($key);
    }
    $plugindata->data ($data);
    $plugindata->save ()
        or return undef;
}

########################################################################

sub set_lexicons {
    my ($param) = @_;
#
    my $original_charset = 'euc';
    my %Lexicon = (
### 全般
    MYNAME => 'LimitCategory',
    TAB_TITLE_CONFIG => '基本設定',
    TAB_TITLE_ABOUT => 'プラグインについて',
### 
    BASIC_SELECT_FIELD_DESC => '記事を投稿できるカテゴリーを投稿者ごとに設定することができます。',
    BASIC_SELECT_NO_CATEGORY => 'このブログにはカテゴリが設定されていません',
    ALERT_CHANGE_ALL => 'このブログの全てのカテゴリの投稿権限を一括で設定します。',
    CHECK_CATEGORY_THIS_USER_CAN_POST => <<PERLHEREDOC,
この投稿者が記事を投稿できるカテゴリーをチェックしてください。<br />
該当するブログが表示されない場合，この投稿者がブログに投稿できるよう投稿者の権限を設定してください。
PERLHEREDOC
###
    ABOUT_DESCRIPTION => <<PERLHEREDOC,
<h3>LimitCategory プラグイン</h3>
このソフトウェアは GPL;
<a href="http://www.opensource.jp/gpl/gpl.ja.html">GNU 一般公衆利用許諾</a>
(<a href="http://www.gnu.org/licenses/gpl.html">英語原文</a>)
の定める範囲において自由に複製、頒布、改変し利用することができます。<br />
サポートおよび最新版の入手に関する情報は
<a href="http://www.magicvox.net/">Open MagicVox.net</a> にある
<a href="http://www.magicvox.net/archive/2007/02102342/">LimitCategory の配布ページ</a>
をご覧ください。<br />
<br />
Copyright &copy; 2007
<a href="mailto:piroli\@magicvox.net">Piroli YUKARINOMIYA</a>.
Some rights reserved.
PERLHEREDOC
    );
    map {
        $param->{$_} = MT::I18N::encode_text (
                $Lexicon{$_}, $original_charset, MT->instance->{cfg}->PublishCharset);
    } keys %Lexicon if $param;
    return \%Lexicon;
}

1;