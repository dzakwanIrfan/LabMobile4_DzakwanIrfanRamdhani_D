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
