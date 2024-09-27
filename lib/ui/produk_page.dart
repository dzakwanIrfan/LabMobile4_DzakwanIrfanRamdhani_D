import 'package:flutter/material.dart';
import 'package:tokokita/model/produk.dart';
import 'package:tokokita/ui/produk_detail.dart';
import 'package:tokokita/ui/produk_form.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  // Placeholder for the product list
  final List<Produk> produkList = [
    Produk(
      id: 1,
      kodeProduk: 'A001',
      namaProduk: 'Kamera Dzakwan',
      hargaProduk: 5000000,
    ),
    Produk(
      id: 2,
      kodeProduk: 'A002',
      namaProduk: 'Kulkas Dzakwan',
      hargaProduk: 2500000,
    ),
    Produk(
      id: 3,
      kodeProduk: 'A003',
      namaProduk: 'Mesin Cuci Dzakwan',
      hargaProduk: 2000000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Produk Dzakwan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              child: const Icon(Icons.add, size: 26.0),
              onTap: () async {
                // Navigate to the form to add a new product
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProdukForm()),
                );
                setState(() {
                  // Refresh the list of products if needed
                });
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Logout Dzakwan'),
              trailing: const Icon(Icons.logout),
              onTap: () async {
                // Implement logout logic here
                // e.g., clear session, navigate to login screen
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: produkList.length,
        itemBuilder: (context, index) {
          return ItemProduk(produk: produkList[index]);
        },
      ),
    );
  }
}

class ItemProduk extends StatelessWidget {
  final Produk produk;

  const ItemProduk({Key? key, required this.produk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProdukDetail(produk: produk),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ListTile(
          title: Text(produk.namaProduk ?? ''),
          subtitle: Text('Rp. ${produk.hargaProduk.toString()}'),
        ),
      ),
    );
  }
}
