import 'package:flutter/material.dart';

/// Layout padrão de todas as páginas do UEPA Social.
///
/// - Fundo com gradiente azul acinzentado (igual ao feed)
/// - Conteúdo centralizado com [maxWidth] (padrão 680)
/// - Responsivo: ocupa 100% em telas pequenas, centraliza em telas grandes
/// - Basta envolver o conteúdo da página com este widget
///
/// Uso básico:
/// ```dart
/// AppPageLayout(
///   child: Column(children: [...]),
/// )
/// ```
///
/// Com scroll (padrão para formulários e listas):
/// ```dart
/// AppPageLayout(
///   scrollable: true,
///   child: Column(children: [...]),
/// )
/// ```
class AppPageLayout extends StatelessWidget {
  const AppPageLayout({
    super.key,
    required this.child,
    this.maxWidth = 680,
    this.scrollable = false,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;

  /// Largura máxima do conteúdo. Padrão: 680.
  final double maxWidth;

  /// Se `true`, envolve o conteúdo em um [ListView] com scroll.
  /// Use para páginas com formulários ou listas longas.
  final bool scrollable;

  /// Padding interno ao redor do conteúdo. Padrão: 16 em todos os lados.
  final EdgeInsets padding;

  static const _gradientColors = [
    Color(0xfff3f6fb),
    Color(0xffdce5f1),
    Color(0xffcfd9e8),
  ];

  @override
  Widget build(BuildContext context) {
    final centeredContent = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _gradientColors,
        ),
      ),
      child: scrollable
          ? ListView(
              children: [centeredContent],
            )
          : centeredContent,
    );
  }
}
