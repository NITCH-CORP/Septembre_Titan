import 'package:flutter/material.dart';
//import 'package:form_field_validator/form_field_validator.dart';
//import 'package:masante228/models/model.dart';

//import '../../../constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key? key,
    required this.formKey,
  }) : super(key: key);

  final GlobalKey formKey;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  late String _userName,
      _email,
      _password,
      _phoneNumber,
      _role,
      _dateNaissance,
      _genre,
      _specialite,
      _autreContact,
      _adresse,
      _estAssure,
      _typeAssurance,
      _estActive;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextFieldName(text: "Nom"),
          TextFormField(
            decoration: const InputDecoration(hintText: "masanté"),
            validator: (value) {
              return null;
            },
            // Let's save our username
            onSaved: (username) => _userName = username!,
          ),
          const SizedBox(height: 10),
          // We will fixed the error soon
          // As you can see, it's a email field
          // But no @ on keybord
          const TextFieldName(text: "Email"),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "test@email.com"),
            validator: (value) {
              return null;
            },
            onSaved: (email) => _email = email!,
          ),
          const SizedBox(height: 10),
          const TextFieldName(text: "Contact"),
          // Same for phone number
          TextFormField(
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: "+22892485339"),
            validator: (value) {
              return null;
            },
            onSaved: (phoneNumber) => _phoneNumber = phoneNumber!,
          ),
          const SizedBox(height: 10),
          const TextFieldName(text: "Mot de passe "),

          TextFormField(
            // We want to hide our password
            obscureText: true,
            decoration: const InputDecoration(hintText: "******"),
            validator: (value) {
              return null;
            },
            onSaved: (password) => _password = password!,
            // We also need to validate our password
            // Now if we type anything it adds that to our password
            onChanged: (pass) => _password = pass,
          ),
          const TextFieldName(text: "Nom"),

          TextFormField(
            decoration: const InputDecoration(hintText: "role"),
            validator: (value) {
              return null;
            },
            // Let's save our username
            onSaved: (role) => _role = role!,
          ),

          const TextFieldName(text: "DateNaissance"),

          TextFormField(
            decoration: const InputDecoration(hintText: "dateNaissance"),
            validator: (value) {
              return null;
            },
            // Let's save our username
            onSaved: (dateNaissance) => _dateNaissance = dateNaissance!,
          ),

          const TextFieldName(text: "Genre"),

          TextFormField(
            decoration: const InputDecoration(hintText: "genre"),
            validator: (value) {
              return null;
            },
            // Let's save our username
            onSaved: (genre) => _genre = genre!,
          ),
          const TextFieldName(text: "Specialite"),

          TextFormField(
            decoration: const InputDecoration(hintText: "specialite"),
            validator: (value) {
              return null;
            },
            // Let's save our username
            onSaved: (specialite) => _specialite = specialite!,
          ),

          const TextFieldName(text: "AutreContact"),

          TextFormField(
            decoration: const InputDecoration(hintText: "autreContact"),
            validator: (value) {
              return null;
            },
            // Let's save our username
            onSaved: (autreContact) => _autreContact = autreContact!,
          ),
          const TextFieldName(text: "Adresse"),

          TextFormField(
            decoration: const InputDecoration(hintText: "adresse"),
            validator: (value) {
              return null;
            },
            // Let's save our username
            onSaved: (adresse) => _adresse = adresse!,
          ),
          const TextFieldName(text: "EstAssuree"),

          TextFormField(
            decoration: const InputDecoration(hintText: "estAssuree"),
            validator: (value) {
              return null;
            },
            // Let's save our username
            onSaved: (estAssuree) => _estAssure = estAssuree!,
          ),

          const TextFieldName(text: "TypeAssurance"),

          TextFormField(
            decoration: const InputDecoration(hintText: "typeAssurance"),
            validator: (value) {
              return null;
            },
            // Let's save our username
            onSaved: (typeAssurance) => _typeAssurance = typeAssurance!,
          ),
          const TextFieldName(text: "EstActive"),

          TextFormField(
            decoration: const InputDecoration(hintText: "estActive"),
            validator: (value) {
              return null;
            },
            // Let's save our username
            onSaved: (active) => _estActive = active!,
          ),

          const SizedBox(height: 10),
          const TextFieldName(text: "Confirmez le mot de passe"),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(hintText: "*****"),
            validator: (value) {
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class TextFieldName extends StatelessWidget {
  const TextFieldName({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10 / 3),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
      ),
    );
  }
}
