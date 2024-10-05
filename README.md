# Tugas Praktikum Mobile Pertemuan 5
## 1. Proses Login
### a. Screenshot form dan isi form
![Screenshot 2024-10-05 134429](https://github.com/user-attachments/assets/2ef94dc8-976b-456b-a402-623f918ff6c0)
### b. SS PopUp Berhasil/Tidak
![Screenshot 2024-10-05 135335](https://github.com/user-attachments/assets/93bee333-e187-49ce-85a7-caf5bd734fc5)
Ada dua komponen utama:
#### _buttonLogin(): Tombol yang memicu validasi formulir dan memanggil API login.
```dart
Widget _buttonLogin() {
  return ElevatedButton(
    child: const Text("Login"),
    onPressed: () {
      var validate = _formKey.currentState!.validate();
      if (validate) {
        if (!_isLoading) _submit();
      }
    },
  );
}
```

#### _submit(): Mengirimkan formulir login, memanggil metode LoginBloc.login(), dan menangani respons (baik keberhasilan atau kegagalan).
Metode _submit() menggunakan LoginBloc untuk memproses login:
``` dart
void _submit() {
  setState(() {
    _isLoading = true;
  });
  LoginBloc.login(
    email: _emailTextboxController.text,
    password: _passwordTextboxController.text,
  ).then((value) async {
    if (value.code == 200) {
      await UserInfo().setToken(value.token ?? "");
      await UserInfo().setUserID(int.tryParse(value.userID.toString()) ?? 0);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => SuccessDialog(
          description: "Login berhasil",
          okClick: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProdukPage()),
            );
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const WarningDialog(
          description: "Login gagal, silahkan coba lagi",
        ),
      );
    }
  });
  setState(() {
    _isLoading = false;
  });
}
```
Pada ```login_bloc.dart``` mengelola proses login dengan mengirimkan permintaan ke API dan memparsing responsnya.
```dart
static Future<Login> login({String? email, String? password}) async {
  String apiUrl = ApiUrl.login;
  var body = {"email": email, "password": password};
  var response = await Api().post(apiUrl, body);
  var jsonObj = json.decode(response.body);
  return Login.fromJson(jsonObj);
}
```
## 2. CRUD Produk
### Create Produk
![Screenshot 2024-10-05 142222](https://github.com/user-attachments/assets/2d42d413-f8c6-49bd-800d-5b43c803e682)
Kode ini terdiri dari dua bagian penting:
- ProdukBloc: Mengelola interaksi dengan API untuk mendapatkan, menambah, mengubah, dan menghapus produk.
- ProdukForm: Formulir yang digunakan untuk menambah atau mengubah produk.

#### ```ProdukBloc``` - Menangani Logika API
```addProduk```: Fungsi ini digunakan untuk menambah produk baru. Data produk seperti kode, nama, dan harga dikirimkan ke endpoint API untuk disimpan di database.
```dart
static Future addProduk({Produk? produk}) async {
  String apiUrl = ApiUrl.createProduk;
  var body = {
    "kode_produk": produk!.kodeProduk,
    "nama_produk": produk.namaProduk,
    "harga": produk.hargaProduk.toString()
  };
  var response = await Api().post(apiUrl, body);
  var jsonObj = json.decode(response.body);
  return jsonObj['status'];
}
```

#### ```ProdukForm``` - Formulir Produk
Textbox: Ada tiga ```TextFormField``` untuk memasukkan Kode Produk, Nama Produk, dan Harga Produk. Masing-masing field memiliki validasi untuk memastikan bahwa data diisi dengan benar.
```dart
Widget _kodeProdukTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Kode Produk"),
    controller: _kodeProdukTextboxController,
    validator: (value) {
      if (value!.isEmpty) {
        return "Kode Produk harus diisi";
      }
      return null;
    },
  );
}
```
Tombol Simpan/Ubah: Tombol ini memeriksa apakah form valid, dan kemudian memanggil fungsi ```simpan()``` jika pengguna menambah produk baru, atau ```ubah()``` jika produk sedang diedit.
```dart
Widget _buttonSubmit() {
  return OutlinedButton(
      child: Text(tombolSubmit),
      onPressed: () {
        var validate = _formKey.currentState!.validate();
        if (validate) {
          if (!_isLoading) {
            if (widget.produk != null) {
              ubah(); // Update produk
            } else {
              simpan(); // Tambah produk baru
            }
          }
        }
      });
}
```
#### Proses Menambah Produk Baru (```simpan()```)
Fungsi ini mengambil data dari form, membentuk objek ```Produk```, lalu mengirimkannya ke API melalui fungsi ```addProduk``` di ```ProdukBloc```. Jika berhasil, pengguna akan diarahkan kembali ke halaman produk.
```dart
simpan() {
  setState(() {
    _isLoading = true;
  });
  Produk createProduk = Produk(id: null);
  createProduk.kodeProduk = _kodeProdukTextboxController.text;
  createProduk.namaProduk = _namaProdukTextboxController.text;
  createProduk.hargaProduk = int.parse(_hargaProdukTextboxController.text);
  ProdukBloc.addProduk(produk: createProduk).then((value) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const ProdukPage()));
  }, onError: (error) {
    showDialog(
        context: context,
        builder: (BuildContext context) => const WarningDialog(
          description: "Simpan gagal, silahkan coba lagi",
        ));
  });
  setState(() {
    _isLoading = false;
  });
}
```

### Read Produk
![Screenshot 2024-10-05 153749](https://github.com/user-attachments/assets/5e56be1a-0b3e-444b-8737-043d1b35f873)
#### FutureBuilder<List>
```dart
body: FutureBuilder<List>(
  future: ProdukBloc.getProduks(),
  builder: (context, snapshot) {
    if (snapshot.hasError) print(snapshot.error);
    return snapshot.hasData
        ? ListProduk(list: snapshot.data)
        : const Center(child: CircularProgressIndicator());
  },
),
```
- FutureBuilder: Widget ini digunakan untuk menampilkan UI berdasarkan hasil dari operasi asynchronous (seperti pengambilan data dari API).
- future: Ini menunjuk ke fungsi ```ProdukBloc.getProduks()```, yang akan mengembalikan daftar produk secara asynchronous.
- snapshot: Representasi dari hasil yang diterima dari ```future```. Jika data sudah siap (berhasil diambil), ```snapshot.hasData``` akan bernilai ```true``` dan akan memanggil widget ```ListProduk```. Jika data belum tersedia, ```CircularProgressIndicator``` (loading spinner) akan ditampilkan.
- Error Handling: Jika ada error dalam pengambilan data, kita memeriksa dengan snapshot.hasError dan mencetak error-nya.

#### ListProduk
```dart
class ListProduk extends StatelessWidget {
  final List? list;
  const ListProduk({Key? key, this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list == null ? 0 : list!.length,
      itemBuilder: (context, i) {
        return ItemProduk(produk: list![i]);
      },
    );
  }
}
```
- ListProduk: Ini adalah widget yang bertanggung jawab untuk menampilkan daftar produk menggunakan ```ListView.builder()```.
- list: Menerima data produk dari ```FutureBuilder``` dalam bentuk daftar (List) dan menampilkan produk satu per satu.
- ListView.builder: Widget ini efisien untuk menampilkan daftar data dalam jumlah besar.
- --itemCount: Menentukan berapa banyak item yang akan ditampilkan (sesuai jumlah produk dalam daftar).
- --itemBuilder: Digunakan untuk membuat widget yang menampilkan setiap produk, dalam hal ini memanggil widget ItemProduk.

### Update Produk
![Screenshot 2024-10-05 154157](https://github.com/user-attachments/assets/d9d4d69e-512d-438e-9e5c-a9f505cba35f)
#### Fungsi ```updateProduk``` di ```ProdukBloc```
```dart
static Future updateProduk({required Produk produk}) async {
  String apiUrl = ApiUrl.updateProduk(int.parse(produk.id!));
  print(apiUrl);
  var body = {
    "kode_produk": produk.kodeProduk,
    "nama_produk": produk.namaProduk,
    "harga": produk.hargaProduk.toString()
  };
  print("Body : $body");
  var response = await Api().put(apiUrl, jsonEncode(body));
  var jsonObj = json.decode(response.body);
  return jsonObj['status'];
}
```
- updateProduk: Fungsi ini digunakan untuk melakukan update produk di server melalui HTTP PUT request.
- apiUrl: URL API diambil dari ```ApiUrl.updateProduk```, di mana ```produk.id``` digunakan untuk membangun URL endpoint yang spesifik untuk produk yang ingin diperbarui.
- body: Membuat data yang akan dikirim ke server dalam format JSON, berisi ```kode_produk```, ```nama_produk```, dan ```harga``` dari produk yang akan di-update. Data ini dikonversi menjadi string JSON menggunakan ```jsonEncode(body)```.
- response: Mengirimkan HTTP PUT request menggunakan method ```Api().put()``` dengan ```apiUrl``` dan body JSON sebagai argumen.
- jsonObj: Merupakan respons JSON yang diterima dari server, yang berisi status apakah update berhasil atau tidak.

#### Menggunakan Fungsi updateProduk pada UI
```dart
IconButton(
  icon: const Icon(Icons.edit),
  onPressed: () async {
    // Pindah ke halaman form produk dengan produk yang dipilih
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProdukForm(produk: produk)),
    );
  },
),
```
- IconButton: Digunakan sebagai tombol untuk memulai proses update, biasanya dalam bentuk ikon edit (pensil).
- Navigator.push: Navigasi ke halaman form produk (```ProdukForm```) sambil membawa objek ```produk``` yang ingin di-edit. Dalam form tersebut, user dapat melakukan perubahan pada data produk.

#### Update dari Form Produk
```dart
ElevatedButton(
  onPressed: () async {
    // Mengambil data produk yang di-edit dari form
    var updatedProduk = Produk(
      id: produk.id,
      kodeProduk: kodeProdukController.text,
      namaProduk: namaProdukController.text,
      hargaProduk: double.parse(hargaController.text),
    );
    // Memanggil fungsi updateProduk dari ProdukBloc
    var status = await ProdukBloc.updateProduk(produk: updatedProduk);

    if (status == "success") {
      // Tampilkan pesan sukses dan navigasi kembali ke halaman sebelumnya
      Navigator.pop(context, 'Produk berhasil diperbarui!');
    } else {
      // Tampilkan pesan error jika update gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui produk')),
      );
    }
  },
  child: const Text('Update Produk'),
),
```
- updatedProduk: Objek ```Produk``` baru yang diperbarui dengan data dari controller (form input).
- updateProduk: Fungsi ini dipanggil dengan parameter ```updatedProduk``` untuk mengirim data ke server.
- status: Jika update berhasil, kita menampilkan pesan sukses dan kembali ke halaman sebelumnya menggunakan ```Navigator.pop()```. Jika gagal, kita menampilkan pesan error menggunakan ```SnackBar```.

#### API URL untuk Update Produk
```dart
class ApiUrl {
  static String updateProduk(int id) => "https://example.com/api/produk/update/$id";
}
```
- updateProduk(int id): Fungsi ini mengembalikan URL untuk update produk, dengan menyertakan ID produk sebagai bagian dari endpoint URL.
