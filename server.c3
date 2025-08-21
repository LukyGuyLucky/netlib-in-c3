/**
 * This file is part of netlib
 * which is licensed under the zlib license
 *
 * github.com/univrsal/netlib
 * netlib is a small network library
 * heavily based on SDL_net without
 * the dependency on SDL
 *
 * Documentation is directly taken from SDL_net
 * I take no credit for this code, I only
 * reformatted it for my needs and made slight changes
 * Source: libsdl.org/projects/SDL_net/docs/demos/tcpserver.c
 */
import netlib;
import libc;
import std::thread;
import std;
alias printf=libc::printf;

const PORT=8080;

fn int main(String[] args)
{
	Ip_address ip;
	defer netlib::quit();

	Ip_address *remoteip;
	
	Tcp_socket server;
	Tcp_socket client;
	defer netlib::tcp_close(server);
	defer netlib::tcp_close(client);

	char[1024] message;
	int len;
	uint server_ip;
	uint ipaddr;
	ushort port;

	/* check our commandline */
	if (args.len<2)
	{
		port=PORT;
	}
	else
	{
		port=(ushort)args[1].to_int()!!;
	}

	/* initialize netlib */
	if (netlib::init() == -1)
	{
		printf("netlib_init: %s\n", netlib::get_error());
		libc::exit(2);
	}



	/* Resolve the argument into an IPaddress type */
	if (netlib::resolve_host(&ip, null, port) == -1)
	{
		printf("netlib_resolve_host: %s\n", netlib::get_error());
		libc::exit(3);
	}
	server_ip = ip.host;
	printf("Started server on %d.%d.%d.%d port %hu\n",
		server_ip >> 24, server_ip >> 16 & 0xff,
		server_ip >> 8 & 0xff, server_ip & 0xff, port);

	/* open the server socket */
	server = netlib::tcp_open(&ip);
	if (!server)
	{
		printf("netlib_tcp_open: %s\n", netlib::get_error());
		libc::exit(4);
	}

	while (1)
	{
		/* try to accept a connection */
		client = netlib::tcp_accept(server);
		if (!client)
		{
			thread::sleep_ms(100);
			continue;
		}

		/* get the clients IP and port number */
		remoteip = netlib::tcp_get_peer_address(client);
		if (!remoteip)
		{
			printf("netlib_tcp_get_peer_address: %s\n", netlib::get_error());
			continue;
		}

		/* print out the clients IP and port number */
		ipaddr = netlib::swap_BE32(remoteip.host);
		printf("Accepted a connection from %d.%d.%d.%d port %hu\n",
			ipaddr >> 24,
			(ipaddr >> 16) & 0xff,
			(ipaddr >> 8) & 0xff,
			ipaddr & 0xff,
			remoteip.port);

		/* read the data from client */
		Netlib_byte_buf* buf = netlib::alloc_byte_buf(20);

		if (!buf)
		{
			printf("netlib_alloc_byte_buf: %s\n", netlib::get_error());
			netlib::tcp_close(client);
			break;
		}

		if (netlib::tcp_receive_buf(client, buf) < buf.length)
		{
			printf("netlib_tcp_close: %s\n", netlib::get_error());
			netlib::tcp_close(client);
			continue;
		}

		/* Recieve data over byte buffer */
		uint a, b;
		int c, d;
		float f = 0.f;

		netlib::read_uint32(buf, &a);
		netlib::read_uint32(buf, &b);
		netlib::read_int32(buf, &c);
		netlib::read_int32(buf, &d);
		netlib::read_float(buf, &f);

		printf("Received: %u %u %i %i %f\n", a, b, c, d, f);
		netlib::free_byte_buf(buf);

		if (message[0] == 'Q')
		{
			printf("Quitting on a Q received\n");
			break;
		}
	}


	return 0;
}