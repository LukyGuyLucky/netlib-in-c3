import libc;


struct Netlib_version
{
    char major;
    char minor;
    char patch;
}

const NETLIB_MAJOR_VERSION=1;
const NETLIB_MINOR_VERSION=0;
const NETLIB_PATHLEVEL=1;

macro netlib_version(x)
{
    x.major=NETLIB_MAJOR_VERSION;
    x.minor=NETLIB_MINOR_VERSION;
    x.patch=NETLIB_PATHLEVEL;
}

extern fn Netlib_version* get_version() @extern("netlib_get_version");

extern fn int init() @extern("netlib_init");
extern fn int quit() @extern("netlib_quit");

struct Ip_address
{
    uint host;
    ushort port;
}

const INADDR_ANY=0x00000000;
const INADDR_NONE=0xFFFFFFFF;

const INADDR_LOOPBACK=0x7f0000001;

const INADDR_BROADCAST=0xFFFFFFFF;

extern fn int resolve_host(Ip_address* address,ZString host,ushort port) @extern("netlib_resolve_host");
extern fn char* resolve_ip(Ip_address* ip) @extern("netlib_resolve_ip");

extern fn int get_local_addresses(Ip_address* addresses,int maxcount) @extern("netlib_get_local_addresses");

alias Tcp_socket=void*;

extern fn Tcp_socket tcp_open(Ip_address* ip) @extern("netlib_tcp_open");

extern fn Tcp_socket tcp_accept(Tcp_socket server) @extern("netlib_tcp_accept");

extern fn Ip_address* tcp_get_peer_address(Tcp_socket sock) @extern("netlib_tcp_get_peer_address");

extern fn int tcp_send(Tcp_socket sock,void* data,int len) @extern("netlib_tcp_send");

extern fn int tcp_receive(Tcp_socket sock,void* data,int maxlen) @extern("netlib_tcp_recv");
extern fn void tcp_close(Tcp_socket sock) @extern("netlib_tcp_close");

const NETLIB_MAX_UDPCHANNELS=32;
const NETLIB_MAX_UPDADDRESSES=4;

alias Udp_socket =void*;
struct Udp_packet
{
    int channel;
    char* data;
    int len;
    int maxlen;
    int status;
    Ip_address address;
}

extern fn Udp_packet* alloc_packet(int size) @extern("netlib_alloc_packet");
extern fn int resize_packet(Udp_packet* pakcket,int newsize) @extern("netlib_resize_packet");
extern fn void free_packet(Udp_packet* packet) @extern("netlib_free_packet");

extern fn Udp_packet** alloc_packets(int howmany,int size) @extern("netlib_alloc_packets");
extern fn void free_packets(Udp_packet** packets) @extern("netlib_free_packets");

extern fn Udp_socket upd_open(ushort port) @extern("netlib_udp_open");

extern fn void udp_set_packet_loss(Udp_socket sock,int percent) @extern("netlib_udp_set_packet_loss");

extern fn int upd_bind(Udp_socket sock,int channel,Ip_address* address) @extern("netlib_udp_bind");

extern fn void udp_unbind(Udp_socket sock,int channel) @extern("netlib_udp_unbind");

extern fn Ip_address* udp_get_peer_address(Udp_socket sock,int channel) @extern("netlib_udp_get_peer_address");

extern fn int udp_send_packets(Udp_socket sock,Udp_packet** packets,int npackets) @extern("netlib_udp_send_packets");

extern fn int udp_send(Udp_socket sock,int channel,Udp_packet* packet) @extern("netlib_udp_send");

extern fn int udp_receive_packets(Udp_socket sock,Udp_packet** packets) @extern("netlib_udp_recv_packets");

extern fn int udp_receive(Udp_socket sock,Udp_packet* packet) @extern("netlib_udp_recv");

extern fn void udp_close(Udp_socket sock) @extern("netlib_udp_close");

alias Netlib_socket_set=void*;

struct Netlib_generic_socket_
{
    int ready;
}

alias Netlib_generic_socket=Netlib_generic_socket_*;

extern fn Netlib_socket_set alloc_socket_set(int maxsockets) @extern("netlib_socket_set");

extern fn int add_socket(Netlib_socket_set set,Netlib_generic_socket sock) @extern("netlib_add_socket");

fn int tcp_add_socket(Netlib_socket_set set,Tcp_socket sock) @extern("netlib_tcp_add_socket")
{
    return add_socket(set,(Netlib_generic_socket)sock);
}

fn int udp_add_socket(Netlib_socket_set set,Udp_socket sock) @extern("netlib_udp_add_socket")
{
    return add_socket(set,(Netlib_generic_socket)sock);
}

extern fn int delete_socket(Netlib_socket_set set,Netlib_generic_socket sock) @extern("netlib_del_socket");

fn int tcp_delete_socket(Netlib_socket_set set,Tcp_socket sock) @extern("netlib_tcp_del_socket")
{
    return delete_socket(set,(Netlib_generic_socket)sock);
}

fn int udp_delete_socket(Netlib_socket_set set,Udp_socket sock) @extern("netlib_udp_del_socket")
{
    return delete_socket(set,(Netlib_generic_socket)sock);
}

extern fn int check_socket_set(Netlib_socket_set set,uint timeout) @extern("netlib_check_socket_set");

macro socket_ready(sock) =>_socket_ready((Netlib_generic_socket)(sock));

fn int _socket_ready(Netlib_generic_socket sock) @extern("_netlib_socket_ready")
{
    return (int)((sock!=null) && (sock.ready));
}

extern fn void free_socket_set(Netlib_socket_set set) @extern("netlib_free_socket_set");

extern fn void set_error(char* fmt,...) @extern("netlib_set_error");

extern fn char* get_error() @extern("netlib_get_error");

macro write16(value,areap) =>_write16(value,areap);
macro write32(value,areap) =>_write32(value,areap);

macro read16(areap) =>_read16(areap);
macro read32(areap) =>_read32(areap);

fn void _write16(ushort value,void* areap) @extern("netlib_write16")
{
    char* area=(char*)areap;
    area[0]=((char)value>>8) & 0xFF;
    area[1]=(char)value & 0xFF;
}
fn void _write32(uint value,void* areap) @extern("netlib_write32")
{
    char* area=(char*)areap;
    area[0]=((char)value>>24) & 0xFF;
    area[1]=((char)value>>16) & 0xFF;
    area[2]=((char)value>>8) & 0xFF;
    area[3]=(char)value & 0xFF;
}


fn ushort _read16(void* areap) @extern("netlib_read16")
{
    char* area=(char*)areap;

    return ((ushort)area[0])<<8 |((ushort)area[1]);
}
fn uint _read32(void* areap) @extern("netlib_read32")
{
    char* area=(char*)areap;

    return ((uint)area[0])<<24|((uint)area[1])<<16|((uint)area[2])<<8|((uint)area[3]);
}

fn uint swap_BE32(uint val) @extern("netlib_swap_BE32")
{
    val=((val<<8) & 0xFF00FF00) | ((val>>8) & 0xFF00FF);

    return (val<<16) | ((val>>16));
}

fn ushort swap_BE16(ushort val) @extern("netlib_swap_BE16")
{
    return (val>>8) |(val<<8);
}


struct Netlib_byte_buf
{
    char* data;
    char length;
    char read_pos;
    char write_pos;
}

extern fn Netlib_byte_buf* alloc_byte_buf(char size) @extern("netlib_alloc_byte_buf");

extern fn void free_byte_buf(Netlib_byte_buf* buf) @extern("netlib_free_byte_buf");

extern fn int tcp_send_buf(Tcp_socket sock,Netlib_byte_buf* buf) @extern("netlib_tcp_send_buf");

extern fn int tcp_send_buf_smart(Tcp_socket sock,Netlib_byte_buf* buf) @extern("netlib_tcp_send_buf_smart");

extern fn int tcp_receive_buf(Tcp_socket sock,Netlib_byte_buf* buf) @extern("netlib_tcp_recv_buf");

extern fn int write_uint8(Netlib_byte_buf* buf,char val) @extern("netlib_write_uint8");
extern fn int write_uint16(Netlib_byte_buf* buf,ushort val) @extern("netlib_write_uin16");
extern fn int write_uint32(Netlib_byte_buf* buf,uint val) @extern("netlib_write_uint32");

macro write_int8(buf,val) =>write_uint8(buf,(char)val);
macro write_int16(buf,val) =>write_uint16((ushort)val);
macro write_int32(buf,val) =>write_uint32(buf,(uint)val);

extern fn int write_float(Netlib_byte_buf* buf,float val) @extern("netlib_write_float");

extern fn int read_uint8(Netlib_byte_buf* buf,char* val) @extern("netlib_read_uint8");
extern fn int read_uint16(Netlib_byte_buf* buf,ushort* val) @extern("netlib_read_uint16");
extern fn int read_uint32(Netlib_byte_buf* buf,uint* val) @extern("netlib_read_uint32");

macro read_int8(buf,val) =>read_uint8(buf,(char*)val);
macro read_int16(buf,val) =>read_uint16(buf,(ushort*)val);
macro read_int32(buf,val) =>read_uint32(buf,(uint*)val);

extern fn int read_float(Netlib_byte_buf* buf,float* val) @extern("netlib_read_float");

