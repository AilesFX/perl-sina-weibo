#!/usr/bin/env perl

# Consumer sends Request Token Request

use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
use HTTP::Request::Common;
use LWP::UserAgent;
use Data::Dumper;
use HTTP::Request;
use JSON;
use Net::OAuth2::Client;


sub app_key  {'1033444714'};
sub app_secret {'1975bd1a6b6d5bbd78d026dee958dc6b'};
sub callback_url {'http://strongbaby.me/weibo/hellostrongpapa'};
sub site {'https://api.weibo.com'};
sub access_token_url {'https://api.weibo.com/oauth2/access_token'};
sub authorize_url {'https://api.weibo.com/oauth2/authorize'};
sub oauth2_path {'https://api.weibo.com/oauth2/'};

sub username {'lweiqiang@gmail.com'};
sub passwd {'52zhuangzhuang'};

sub client {
	Net::OAuth2::Client->new (
		app_key(),
		app_secret(),
		site => site(),
		authorize_url=authorize_url(),
		access_token_url=access_token_url(),
	)->web_server(redirect_uri => callback_url());

}
