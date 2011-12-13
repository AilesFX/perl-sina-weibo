#!/usr/bin/env perl

# Consumer sends Request Token Request

use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
use HTTP::Request::Common;
use LWP::UserAgent;
use Data::Dumper;
use HTTP::Request;
use JSON;



sub app_key  {'1033444714'};
sub app_secret {'1975bd1a6b6d5bbd78d026dee958dc6b'};
sub request_token_url {'http://api.t.sina.com.cn/oauth/request_token'};
sub callback_url {'http://strongbaby.me/weibo/hellostrongpapa'};
sub access_token_url {'http://api.t.sina.com.cn/oauth/access_token'};
sub authorize_url {'http://api.t.sina.com.cn/oauth/authorize'};
sub username {'lweiqiang@gmail.com'};
sub passwd {'PdhM?007'};

sub nonce {
    my @a = ('A'..'Z', 'a'..'z', 0..9);
    my $nonce ='';
    for (0..31) {
        $nonce .= $a[rand(scalar (@a))];
    }
    $nonce;
}

sub get_request_token() {
	my $ua = LWP::UserAgent->new;
	
	my $request = Net::OAuth->request("request token")->new(
	    consumer_key => app_key(),
	    consumer_secret => app_secret(),
	    request_url => request_token_url(),
	    request_method => 'POST',
	    signature_method => 'HMAC-SHA1',
	    timestamp => time(),
	    nonce => nonce(),
	    callback => callback_url(),
	);
	
	$request->sign;
	
	#print Dumper($request->to_url());
	#print Dumper($request->to_hash());
	#print "\n${$request}{request_url}\n";
	
	
	my $res = $ua->request(POST $request->to_url); # Post message to the Service Provider
	
	if ($res->is_success) {
		#print Dumper($res->content);
	    my $response = eval {Net::OAuth->response('request token')->from_post_body($res->content)};
		if ($@) {
			if ($@ =~ /Missing required parameter 'callback_confirmed'/) {
				# fall back to OAuth 1.0
				$response = Net::OAuth->response('request token')->from_post_body(
					$res->content, 
					protocol_version => Net::OAuth::PROTOCOL_VERSION_1_0
				);
				$is_oauth_1_0 = 1; # from now on treat the server as OAuth 1.0 compliant
			}
			else {
				die $@;
			}
		}
		#print Dumper($response);	
	    print "Got Request Token : ", $response->token, "\n";
	    print "Got Request Token Secret : ", $response->token_secret, "\n";
		return ($response->token, $response->token_secret);
	}
	else {
	    die "Something went wrong";
	}
};

sub get_auth_token {
	my ($request_token) = @_;
	my $ua = LWP::UserAgent->new;
	my $request = HTTP::Request->new(GET =>
		authorize_url()."?oauth_token=$request_token&oauth_callback=json&userId=".username().
		"&passwd=".passwd()
		);

#	print Dumper($request);	
	
	my $res = $ua->request($request); # Post message to the Service Provider
	print Dumper($res->content);
	
	if ($res->is_success) {
		my $response = decode_json($res->content);
		print Dumper($response);
	    print "Got Auth Token : ${$response}{oauth_token}\n";
	    print "Got Auth Verifier : ${$response}{oauth_verifier}\n";
		return (${$response}{oauth_token}, ${$response}{oauth_verifier});
	}
	else {
	    die "Something went wrong ";
	}
}


sub get_access_token {
	my ($oauth_token, $oauth_token_secret, $oauth_verifier)  = @_;

	my $ua = LWP::UserAgent->new;
	
	my $request = Net::OAuth->request("request token")->new(
	    consumer_key => app_key(),
	    consumer_secret => app_secret(),
	    request_url => access_token_url(),
	    request_method => 'POST',
	    signature_method => 'HMAC-SHA1',
	    timestamp => time(),
	    nonce => nonce(),
	    callback => callback_url(),
		token =>$oauth_token,
		token_secret=>$oauth_token_secret,
		verifier => $oauth_verifier,
		version => 1.0,
	);
	
	$request->sign;
	print Dumper($request);
	
	my $res = $ua->request(POST $request->to_url); # Post message to the Service Provider
	print Dumper($res);
	
	if ($res->is_success) {
	    my $response = eval {Net::OAuth->response('access token')->from_post_body($res->content)};
		if ($@) {
			if ($@ =~ /Missing required parameter 'callback_confirmed'/) {
				# fall back to OAuth 1.0
				$response = Net::OAuth->response('access token')->from_post_body(
					$res->content, 
					protocol_version => Net::OAuth::PROTOCOL_VERSION_1_0
				);
				$is_oauth_1_0 = 1; # from now on treat the server as OAuth 1.0 compliant
			}
			else {
				die $@;
			}
		}
		
	    print "Got Access Token ", $response->token, "\n";
	    print "Got Access Token Secret ", $response->token_secret, "\n";
	}
	else {
	    die "Something went wrong ";
	}
}


my @request_token = get_request_token();
my ($oauth_token, $oauth_verifier) = get_auth_token(@request_token);
print "Oauth_token=$oauth_token, Oauth_verifier=$oauth_verifier\n";
get_access_token(@request_token, $oauth_verifier);

