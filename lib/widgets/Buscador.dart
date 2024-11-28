import 'package:flutter/material.dart';

class SearchBarPers extends StatefulWidget {
  final VoidCallback onTap;
  final String detalle;
  final String detalleAlBuscar;

  const SearchBarPers(
      {super.key,
      required this.onTap,
      required this.detalle,
      required this.detalleAlBuscar});

  @override
  State<SearchBarPers> createState() => _SearchBarPersState();
}

class _SearchBarPersState extends State<SearchBarPers>
    with SingleTickerProviderStateMixin {
  bool _isActive = false;
  final double padings_V = 25;
  final FocusNode _focusNode = FocusNode();
  final String busqueda = '';

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padings_V),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: -5,
              blurRadius: 8,
              offset: Offset(-5, -5),
            ),
          ],
        ),
        child: TextButton(
          onPressed: () {
            widget.onTap();
            setState(() {
              _isActive = true;
              _focusNode.requestFocus();
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!_isActive)
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    widget.detalle,
                    //style: Theme.of(context).appBarTheme.titleTextStyle,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 125),
                    child: _isActive
                        ? Container(
                            alignment: Alignment.centerLeft,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                if (!hasFocus) {
                                  setState(() {
                                    _isActive = false;
                                  });
                                }
                              },
                              child: TextField(
                                focusNode: _focusNode,
                                onTap: () {
                                  setState(() {
                                    _isActive = true;
                                  });
                                },
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                ),
                                enableSuggestions: false,
                                onChanged: (value) => busqueda,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  //aqui esta el detalle al bucar
                                  hintText: widget.detalleAlBuscar,
                                  focusColor:
                                      const Color.fromARGB(255, 0, 0, 0),
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isActive = false;
                                      });
                                      _focusNode.unfocus();
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                widget.onTap();
                                _isActive = true;
                                _focusNode.requestFocus();
                              });
                            },
                            icon: const Icon(Icons.search),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
