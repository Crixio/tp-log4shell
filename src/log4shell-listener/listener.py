from dnslib.server import DNSServer, BaseResolver
from dnslib import RR, QTYPE, A


class Resolver(BaseResolver):
    def resolve(self, request, handler):
        qname = str(request.q.qname)

        print(f"\n[+] CALLBACK DNS reçu !")
        print(f"    Nom demandé : {qname}")
        print(f"    Type        : {QTYPE[request.q.qtype]}")

        reply = request.reply()

        # Réponse DNS inoffensive
        reply.add_answer(
            RR(
                qname,
                QTYPE.A,
                rdata=A("127.0.0.1"),
                ttl=60
            )
        )

        return reply


resolver = Resolver()

server = DNSServer(
    resolver,
    address="0.0.0.0",
    port=8053
)

print("[*] Serveur DNS de démonstration lancé sur UDP/8053")
server.start()
