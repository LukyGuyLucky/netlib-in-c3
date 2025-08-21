import netlib;
import libc;
import std;

alias printf=libc::printf;

const MAX_ADDRESSES  = 10;
const HOST_NAME="127.0.0.1";
const PORT_NAME=8080;

fn void show_interfaces()
{
	Ip_address[MAX_ADDRESSES] addresses;
	int i, count;

	count = netlib::get_local_addresses(&addresses, MAX_ADDRESSES);
	printf("Found %d local addresses\n", count);
	for (i = 0; i < count; ++i) {
		printf("%d: %d.%d.%d.%d - %s\n", i + 1,
			(addresses[i].host >> 0) & 0xFF,
			(addresses[i].host >> 8) & 0xFF,
			(addresses[i].host >> 16) & 0xFF,
			(addresses[i].host >> 24) & 0xFF,
			netlib::resolve_ip(&addresses[i]));
	}
}

fn int main(String[] args)
{
	show_interfaces();

	Ip_address ip;
	defer netlib::quit();

	Tcp_socket sock;
	defer netlib::tcp_close(sock);

	char[1024] message;
	int len;
	ushort port;
	String host;

	/* check our commandline */
	if (args.len<3)
	{
		printf("usage:\n client.exe [host] [port]\n");
		printf("Using host=%s\tport=%d instead.\n",HOST_NAME,PORT_NAME);

		host=HOST_NAME;
		port=PORT_NAME;
		
	}
	else
	{
		host=args[1];
		port=(ushort)args[2].to_int()!!;
	}

	
	/* initialize netlib */
	if (netlib::init() == -1)
	{
		printf("netlib_init: %s\n", netlib::get_error());
		libc::exit(2);
	}

	/* get the port from the commandline */
	//port = (uint16_t)strtol(argv[2], NULL, 0);

	/* Resolve the argument into an IPaddress type */
	if (netlib::resolve_host(&ip, host.zstr_tcopy(), port) == -1)
	{
		printf("netlib_resolve_host: %s\n", netlib::get_error());
		libc::exit(3);
	}

	/* open the server socket */
	sock = netlib::tcp_open(&ip);
	if (!sock)
	{
		printf("netlib_tcp_open: %s\n", netlib::get_error());
		libc::exit(4);
	}

	Netlib_byte_buf* buf = netlib::alloc_byte_buf(20);
	defer netlib::free_byte_buf(buf);

	netlib::write_uint32(buf, uint.min);
	netlib::write_uint32(buf, 0);
	netlib::write_int32(buf, int.max);
	netlib::write_int32(buf, uint.min);
	netlib::write_float(buf, 1.337f);

	if (netlib::tcp_send_buf(sock, buf) < buf.length)
	{
		printf("netlib_tcp_send: %s\n", netlib::get_error());
	}

	

	return 0;
}