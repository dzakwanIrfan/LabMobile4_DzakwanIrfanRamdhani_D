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
