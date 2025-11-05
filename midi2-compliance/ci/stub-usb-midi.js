const fakeDeviceId = 'stub-ump-device';
const fakeDevice = {
  devId: fakeDeviceId,
  clientName: 'Stub Compliance Device',
  blocks: [
    {
      fbIdx: 0,
      gbNum: 0,
      numOfGroups: 1,
      dir: 3,
      name: 'Stub Function Block',
    },
  ],
  usbDetails: {
    iManufacturer: 'Stub Org',
    iProduct: 'Stub Compliance Device',
    iSerialNumber: '0001',
    groupBlocks: [
      {
        gbNum: 0,
        numOfGroups: 1,
        dir: 3,
        name: 'Stub Function Block',
      },
    ],
  },
};

let recvCallback = null;
let newDeviceCallback = null;
let removeCallback = null;

function setRecvMIDI(cb) {
  recvCallback = cb;
}

function setNewDeviceAlert(cb) {
  newDeviceCallback = cb;
  // simulate async discovery so the UI has time to boot
  setTimeout(() => {
    if (typeof cb === 'function') {
      cb(fakeDeviceId, { ...fakeDevice });
    }
  }, 200);
}

function setRemoveDeviceAlert(cb) {
  removeCallback = cb;
}

function sendMIDI(devId, ump) {
  // Echo minimal responses so Workbench state machines continue to advance.
  if (!Array.isArray(ump) || !recvCallback) {
    return;
  }
  // Basic echo with slight delay to emulate round-trip without creating loops.
  setTimeout(() => {
    try {
      recvCallback(devId, Array.isArray(ump) ? [...ump] : ump);
    } catch (err) {
      console.error('[stub-usb-midi] failed to echo UMP', err);
    }
  }, 25);
}

function getUSBDescriptors() {
  return { ...fakeDevice.usbDetails };
}

module.exports = {
  setRecvMIDI,
  setNewDeviceAlert,
  setRemoveDeviceAlert,
  sendMIDI,
  getUSBDescriptors,
};
