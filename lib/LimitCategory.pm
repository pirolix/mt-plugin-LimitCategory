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
### ����
    MYNAME => 'LimitCategory',
    TAB_TITLE_CONFIG => '��������',
    TAB_TITLE_ABOUT => '�ץ饰����ˤĤ���',
### 
    BASIC_SELECT_FIELD_DESC => '��������ƤǤ��륫�ƥ��꡼����ƼԤ��Ȥ����ꤹ�뤳�Ȥ��Ǥ��ޤ���',
    BASIC_SELECT_NO_CATEGORY => '���Υ֥��ˤϥ��ƥ��꤬���ꤵ��Ƥ��ޤ���',
    ALERT_CHANGE_ALL => '���Υ֥������ƤΥ��ƥ������Ƹ��¤�������ꤷ�ޤ���',
    CHECK_CATEGORY_THIS_USER_CAN_POST => <<PERLHEREDOC,
������ƼԤ���������ƤǤ��륫�ƥ��꡼������å����Ƥ���������<br />
��������֥���ɽ������ʤ���硤������ƼԤ��֥�����ƤǤ���褦��ƼԤθ��¤����ꤷ�Ƥ���������
PERLHEREDOC
###
    ABOUT_DESCRIPTION => <<PERLHEREDOC,
<h3>LimitCategory �ץ饰����</h3>
���Υ��եȥ������� GPL;
<a href="http://www.opensource.jp/gpl/gpl.ja.html">GNU ���̸������ѵ���</a>
(<a href="http://www.gnu.org/licenses/gpl.html">�Ѹ츶ʸ</a>)
�������ϰϤˤ����Ƽ�ͳ��ʣ�������ۡ����Ѥ����Ѥ��뤳�Ȥ��Ǥ��ޤ���<br />
���ݡ��Ȥ���Ӻǿ��Ǥ�����˴ؤ�������
<a href="http://www.magicvox.net/">Open MagicVox.net</a> �ˤ���
<a href="http://www.magicvox.net/archive/2007/02102342/">LimitCategory �����ۥڡ���</a>
��������������<br />
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