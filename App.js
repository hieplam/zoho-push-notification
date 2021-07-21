/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import type {Node} from 'react';
import {SafeAreaView, ScrollView, StyleSheet, Button, View} from 'react-native';
import {
  ZDPortalChat,
  ZohoDeskPortalSDK,
  ZDPortalHome,
} from 'react-native-zohodesk-portal-sdk';
function onSendMessage() {
  console.log('send msg click');
  login('lamhiep16@gmail.com');
  ZDPortalHome.show();
}
function initZoho() {
  ZohoDeskPortalSDK.initialise('your_app_id', 'your_org_id', 'US');

  ZohoDeskPortalSDK.enableLogs();
  ZohoDeskPortalSDK.enablePush();
}
function login(email) {
  return new Promise((resolve, reject) => {
    console.log('-------login as ' + email);
    ZohoDeskPortalSDK.setUserToken(
      email,
      msg => {
        this._loginEmail = email;
        console.log('-----Login successfully ' + msg);
        resolve(msg);
      },
      msg => {
        console.log('-----Login error ' + msg);
        reject(msg);
      },
    );
  });
}
const Separator = () => <View style={styles.separator} />;

const App: () => Node = () => {
  initZoho();
  return (
    <SafeAreaView>
      <ScrollView contentInsetAdjustmentBehavior="automatic">
        <View style={styles.container}>
          <Button
            onPress={onSendMessage}
            title="Send Message"
            color="orange"
            accessibilityLabel="Learn more about this orange button"
          />
          <Separator />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
  container: {flexDirection: 'column'},
});

export default App;
