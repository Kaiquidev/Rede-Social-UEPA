import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const UepaApp());
}

class UepaApp extends StatelessWidget {
  const UepaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UEPA Social',
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

enum TipoOrdenacao { nomeAZ, nomeZA, cursoAZ, cursoZA }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode focus = FocusNode();

  bool pesquisando = false;
  String busca = '';
  TipoOrdenacao ordenacaoAtual = TipoOrdenacao.nomeAZ;

  final List<Map<String, String>> alunos = [
    {"nome": "Yolando Jr", "curso": "Engenharia de Software"},
    {"nome": "Kaiqui Jr", "curso": "Badeco do TI"},
    {"nome": "Gabriel Nascimento", "curso": "Pucha Saco de Patrao"},
    {"nome": "Daniel Rocha", "curso": "Sistemas"},
    {"nome": "Ana Souza", "curso": "Medicina"},
    {"nome": "Bruno Lima", "curso": "Enfermagem"},
    {"nome": "Carla Santos", "curso": "Direito"},
    {"nome": "Eduarda Silva", "curso": "Biomedicina"},
    {"nome": "Felipe Costa", "curso": "Farmácia"},
    {"nome": "Gabriela Nunes", "curso": "Pedagogia"},
    {"nome": "Henrique Alves", "curso": "Educação Física"},
    {"nome": "Isabela Moraes", "curso": "Medicina"},
    {"nome": "João Pedro", "curso": "Enfermagem"},
    {"nome": "Karen Dias", "curso": "Direito"},
    {"nome": "Lucas Martins", "curso": "Sistemas"},
    {"nome": "Mariana Freitas", "curso": "Biomedicina"},
    {"nome": "Nicolas Barros", "curso": "Farmácia"},
    {"nome": "Olivia Cardoso", "curso": "Pedagogia"},
    {"nome": "Paulo Henrique", "curso": "Educação Física"},
    {"nome": "Quezia Araujo", "curso": "Medicina"},
    {"nome": "Rafael Teixeira", "curso": "Enfermagem"},
    {"nome": "Sara Batista", "curso": "Direito"},
    {"nome": "Thiago Gomes", "curso": "Sistemas"},
    {"nome": "Ursula Pires", "curso": "Biomedicina"},
    {"nome": "Vitor Hugo", "curso": "Farmácia"},
    {"nome": "Wesley Moura", "curso": "Pedagogia"},
    {"nome": "Xenia Castro", "curso": "Educação Física"},
    {"nome": "Yasmin Oliveira", "curso": "Medicina"},
    {"nome": "Zeca Farias", "curso": "Enfermagem"},
    {"nome": "Amanda Ribeiro", "curso": "Direito"},
    {"nome": "Beatriz Correia", "curso": "Sistemas"},
    {"nome": "Caio Pinheiro", "curso": "Biomedicina"},
    {"nome": "Debora Duarte", "curso": "Farmácia"},
    {"nome": "Emanuel Lopes", "curso": "Pedagogia"},
    {"nome": "Fernanda Cruz", "curso": "Educação Física"},
    {"nome": "Gustavo Maia", "curso": "Medicina"},
    {"nome": "Helena Monteiro", "curso": "Enfermagem"},
    {"nome": "Igor Souza", "curso": "Direito"},
    {"nome": "Juliana Ramos", "curso": "Sistemas"},
    {"nome": "Kleber Vieira", "curso": "Biomedicina"},
    {"nome": "Larissa Campos", "curso": "Farmácia"},
    {"nome": "Mateus Mendes", "curso": "Pedagogia"},
    {"nome": "Nicole Fernandes", "curso": "Educação Física"},
    {"nome": "Otavio Sousa", "curso": "Medicina"},
    {"nome": "Priscila Carvalho", "curso": "Enfermagem"},
    {"nome": "Renan Barbosa", "curso": "Direito"},
    {"nome": "Sabrina Melo", "curso": "Sistemas"},
    {"nome": "Talita Reis", "curso": "Biomedicina"},
    {"nome": "Vinicius Torres", "curso": "Farmácia"},
    {"nome": "William Nascimento", "curso": "Pedagogia"},
    {"nome": "Aline Barbosa", "curso": "Educação Física"},
    {"nome": "Breno Lemos", "curso": "Medicina"},
    {"nome": "Cecilia Martins", "curso": "Enfermagem"},
  ];

  List<Map<String, String>> recentes = [
    {"nome": "Yolando Jr", "curso": "Engenharia de Software"},
    {"nome": "Kaiqui Jr", "curso": "Badeco do TI"},
    {"nome": "Gabriel Nascimento", "curso": "Pucha Saco de Patrao"},
    {"nome": "Daniel Rocha", "curso": "Sistemas"},
  ];

  List<Map<String, String>> get resultados {
    List<Map<String, String>> lista;

    if (busca.trim().isEmpty) {
      lista = List<Map<String, String>>.from(alunos);
    } else {
      final texto = busca.toLowerCase();
      lista = alunos.where((a) {
        final nome = a["nome"]!.toLowerCase();
        final curso = a["curso"]!.toLowerCase();
        return nome.contains(texto) || curso.contains(texto);
      }).toList();
    }

    lista.sort((a, b) {
      final nomeA = a['nome']!.toLowerCase();
      final nomeB = b['nome']!.toLowerCase();
      final cursoA = a['curso']!.toLowerCase();
      final cursoB = b['curso']!.toLowerCase();

      switch (ordenacaoAtual) {
        case TipoOrdenacao.nomeAZ:
          return nomeA.compareTo(nomeB);
        case TipoOrdenacao.nomeZA:
          return nomeB.compareTo(nomeA);
        case TipoOrdenacao.cursoAZ:
          final cursoCompare = cursoA.compareTo(cursoB);
          return cursoCompare != 0 ? cursoCompare : nomeA.compareTo(nomeB);
        case TipoOrdenacao.cursoZA:
          final cursoCompare = cursoB.compareTo(cursoA);
          return cursoCompare != 0 ? cursoCompare : nomeA.compareTo(nomeB);
      }
    });

    return lista;
  }

  void abrirTeclado() {
    setState(() {
      pesquisando = true;
    });
    focus.requestFocus();
  }

  void fecharTeclado() {
    focus.unfocus();

    setState(() {
      pesquisando = false;
      searchController.clear();
      busca = '';
    });
  }

  void digitar(String texto) {
    setState(() {
      searchController.text += texto;
      busca = searchController.text;
    });
  }

  void adicionarEspaco() {
    if (searchController.text.isNotEmpty &&
        !searchController.text.endsWith(' ')) {
      setState(() {
        searchController.text += ' ';
        busca = searchController.text;
      });
    }
  }

  void apagar() {
    if (searchController.text.isEmpty) return;

    setState(() {
      searchController.text = searchController.text.substring(
        0,
        searchController.text.length - 1,
      );
      busca = searchController.text;
    });
  }

  void limparTudo() {
    setState(() {
      searchController.clear();
      busca = '';
    });
  }

  void confirmar() {
    focus.unfocus();
    setState(() {
      pesquisando = false;
      busca = searchController.text;
    });
  }

  void acessarPerfil(Map<String, String> aluno) {
    setState(() {
      recentes.removeWhere((item) => item['nome'] == aluno['nome']);
      recentes.insert(0, aluno);

      if (recentes.length > 4) {
        recentes = recentes.take(4).toList();
      }
    });
  }

  Widget tecla({
    required String texto,
    required VoidCallback onTap,
    double largura = 1,
    Color? cor,
    Color? corTexto,
    IconData? icone,
  }) {
    return Expanded(
      flex: (largura * 100).toInt(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              elevation: 1,
              backgroundColor: cor ?? Colors.white,
              foregroundColor: corTexto ?? const Color(0xff0a5c7a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: icone != null
                ? Icon(icone, size: 20)
                : Text(
                    texto,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget linhaTeclado(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: children),
    );
  }

  Widget teclado() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 40, end: 0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, value), child: child);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        decoration: BoxDecoration(
          color: const Color(0xffeef9ff),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 14,
              offset: Offset(0, -4),
            ),
          ],
          border: Border.all(color: const Color(0xffcfefff)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 5,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            linhaTeclado([
              tecla(texto: 'Q', onTap: () => digitar('Q')),
              tecla(texto: 'W', onTap: () => digitar('W')),
              tecla(texto: 'E', onTap: () => digitar('E')),
              tecla(texto: 'R', onTap: () => digitar('R')),
              tecla(texto: 'T', onTap: () => digitar('T')),
              tecla(texto: 'Y', onTap: () => digitar('Y')),
              tecla(texto: 'U', onTap: () => digitar('U')),
              tecla(texto: 'I', onTap: () => digitar('I')),
              tecla(texto: 'O', onTap: () => digitar('O')),
              tecla(texto: 'P', onTap: () => digitar('P')),
            ]),
            linhaTeclado([
              tecla(texto: 'A', onTap: () => digitar('A')),
              tecla(texto: 'S', onTap: () => digitar('S')),
              tecla(texto: 'D', onTap: () => digitar('D')),
              tecla(texto: 'F', onTap: () => digitar('F')),
              tecla(texto: 'G', onTap: () => digitar('G')),
              tecla(texto: 'H', onTap: () => digitar('H')),
              tecla(texto: 'J', onTap: () => digitar('J')),
              tecla(texto: 'K', onTap: () => digitar('K')),
              tecla(texto: 'L', onTap: () => digitar('L')),
            ]),
            linhaTeclado([
              tecla(
                texto: '',
                icone: Icons.backspace_outlined,
                onTap: apagar,
                largura: 1.4,
                cor: const Color(0xffd8eef8),
              ),
              tecla(texto: 'Z', onTap: () => digitar('Z')),
              tecla(texto: 'X', onTap: () => digitar('X')),
              tecla(texto: 'C', onTap: () => digitar('C')),
              tecla(texto: 'V', onTap: () => digitar('V')),
              tecla(texto: 'B', onTap: () => digitar('B')),
              tecla(texto: 'N', onTap: () => digitar('N')),
              tecla(texto: 'M', onTap: () => digitar('M')),
              tecla(
                texto: 'OK',
                onTap: confirmar,
                largura: 1.4,
                cor: const Color(0xff159ac7),
                corTexto: Colors.white,
              ),
            ]),
            linhaTeclado([
              tecla(texto: '1', onTap: () => digitar('1')),
              tecla(texto: '2', onTap: () => digitar('2')),
              tecla(texto: '3', onTap: () => digitar('3')),
              tecla(texto: '4', onTap: () => digitar('4')),
              tecla(texto: '5', onTap: () => digitar('5')),
              tecla(texto: '6', onTap: () => digitar('6')),
              tecla(texto: '7', onTap: () => digitar('7')),
              tecla(texto: '8', onTap: () => digitar('8')),
              tecla(texto: '9', onTap: () => digitar('9')),
              tecla(texto: '0', onTap: () => digitar('0')),
            ]),
            linhaTeclado([
              tecla(
                texto: 'Limpar',
                onTap: limparTudo,
                largura: 1.6,
                cor: const Color(0xfffff0f0),
                corTexto: Colors.redAccent,
              ),
              tecla(
                texto: 'Espaço',
                onTap: adicionarEspaco,
                largura: 2.8,
                cor: const Color(0xffffffff),
              ),
              tecla(
                texto: 'Fechar',
                onTap: fecharTeclado,
                largura: 1.6,
                cor: const Color(0xffd8eef8),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget perfilCard(Map<String, String> aluno) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => acessarPerfil(aluno),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xffeaf8ff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xff159ac7),
              child: Text(
                aluno["nome"]![0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              aluno["nome"]!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              aluno["curso"]!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<TipoOrdenacao> itemOrdenacao({
    required TipoOrdenacao valor,
    required IconData icone,
    required String texto,
  }) {
    final bool selecionado = ordenacaoAtual == valor;

    return PopupMenuItem<TipoOrdenacao>(
      value: valor,
      child: Row(
        children: [
          Icon(
            icone,
            size: 18,
            color: selecionado ? const Color(0xff159ac7) : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (selecionado)
            const Icon(Icons.check_rounded, size: 18, color: Color(0xff159ac7)),
        ],
      ),
    );
  }

  Widget botaoFiltro() {
    return PopupMenuButton<TipoOrdenacao>(
      tooltip: 'Filtrar e ordenar',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 8,
      onSelected: (valor) {
        setState(() {
          ordenacaoAtual = valor;
        });
      },
      itemBuilder: (context) => [
        itemOrdenacao(
          valor: TipoOrdenacao.nomeAZ,
          icone: Icons.sort_by_alpha,
          texto: 'Nome A-Z',
        ),
        itemOrdenacao(
          valor: TipoOrdenacao.nomeZA,
          icone: Icons.sort_by_alpha,
          texto: 'Nome Z-A',
        ),
        itemOrdenacao(
          valor: TipoOrdenacao.cursoAZ,
          icone: Icons.school_outlined,
          texto: 'Curso A-Z',
        ),
        itemOrdenacao(
          valor: TipoOrdenacao.cursoZA,
          icone: Icons.school_outlined,
          texto: 'Curso Z-A',
        ),
      ],
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffd6eef8)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.tune_rounded,
          color: Color(0xff0a5c7a),
          size: 20,
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool temBusca = busca.trim().isNotEmpty;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (pesquisando) {
            fecharTeclado();
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffdff4ff), Color(0xffc8ecff), Color(0xffe9f9ff)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff0a5c7a), Color(0xff159ac7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Color(0xff0a5c7a)),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Trio UEPA",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: searchController,
                        focusNode: focus,
                        readOnly: true,
                        onTap: abrirTeclado,
                        decoration: InputDecoration(
                          hintText: "Pesquisar aluno ou curso...",
                          filled: true,
                          fillColor: Colors.white,

                          prefixIcon: busca.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.cleaning_services_outlined,
                                  ),
                                  onPressed: limparTudo,
                                )
                              : const Icon(Icons.search),

                          suffixIcon: busca.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: limparTudo,
                                )
                              : null,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!pesquisando && !temBusca) ...[
                          const Text(
                            "Últimos acessados",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentes.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.9,
                                ),
                            itemBuilder: (_, i) => perfilCard(recentes[i]),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                temBusca
                                    ? "Resultados encontrados"
                                    : "Perfis de alunos",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            botaoFiltro(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: resultados.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.9,
                              ),
                          itemBuilder: (_, i) => perfilCard(resultados[i]),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: pesquisando
                      ? ClipRect(
                          key: const ValueKey('teclado'),
                          child: teclado(),
                        )
                      : const SizedBox.shrink(key: ValueKey('sem_teclado')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
