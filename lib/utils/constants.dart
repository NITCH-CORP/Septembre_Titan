// ignore_for_file: constant_identifier_names

import 'package:appwrite/appwrite.dart';

const keyApplicationId = 'UgwFTudAeq3F9i5Ss1yCUw4fypAFUY1JWH9L3kp3';
const keyParseServerUrl = 'http://10.0.2.2:1337/parse';

const DATABASE_ID = '649e927401c0acc26674';
const CLIENT_COLLECTION_ID = '649e929a84c3027d0d96';
const PILOTE_COLLECTION_ID = '649e92a23a1e61c67be7';
const TRAJET_COLLECTION_ID = '64b65407e81212d9723b';
const NOTE_COLLECTION_ID = '64c27308af797fb2aa48';
const NOTIFICATION_COLLECTION_ID = '64a537d9d388a6fe6917';
const POSITION_COLLECTION_ID = '64ad9ba7ca44f75892e5';
const ACTIVITE_COLLECTION_ID = '64a15cf0b006c6517dfc';
const ENTREPRISE_COLLECTION_ID = '64b52d431187342ee338';
const RECHERCHE_COLLECTION_ID = '64d05e470e92d554d1bf';
const EMAIL_URL = '192.168.30.227';
const BASE_URL = '192.168.167.1';

final client = Client()
    .setEndpoint('http://${BASE_URL}/v1')
    .setProject('649dac4663b619d61755')
    .setSelfSigned(status: true);
final account = Account(client);
final databases = Databases(client);

//192.168.167.1