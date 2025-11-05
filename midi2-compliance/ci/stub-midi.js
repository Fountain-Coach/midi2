const stubState = {
  inputs: ['Stub Compliance In'],
  outputs: ['Stub Compliance Out'],
};

class BasePort {
  constructor(kind) {
    this._kind = kind;
    this._name = kind === 'in' ? stubState.inputs[0] : stubState.outputs[0];
    this._port = 0;
    this._virtual = false;
    this._virtualOpen = false;
    this._isOpen = false;
    this._messageHandler = null;
    this._UMPConnections = {};
  }

  on(event, handler) {
    if (event === 'message') {
      this._messageHandler = handler;
    }
  }

  ignoreTypes() {
    // no-op in stub
  }

  closePort() {
    this._isOpen = false;
    this._virtualOpen = false;
  }

  end() {
    this.closePort();
  }

  unpublish() {
    this.closePort();
  }

  isPortOpen() {
    return this._isOpen;
  }
}

class StubInput extends BasePort {
  constructor() {
    super('in');
  }

  getPortCount() {
    return stubState.inputs.length;
  }

  getPortName(index) {
    return stubState.inputs[index] || `Stub Input ${index}`;
  }

  openPort(index) {
    this._port = index;
    this._name = this.getPortName(index);
    this._virtual = false;
    this._isOpen = true;
  }

  openVirtualPort(name) {
    this._name = name || this._name;
    this._virtual = true;
    this._virtualOpen = true;
    this._isOpen = true;
  }

  emitMessage(message) {
    if (this._messageHandler) {
      try {
        this._messageHandler(0, message);
      } catch (err) {
        console.error('[stub-midi] failed to emit message', err);
      }
    }
  }
}

class StubOutput extends BasePort {
  constructor() {
    super('out');
  }

  getPortCount() {
    return stubState.outputs.length;
  }

  getPortName(index) {
    return stubState.outputs[index] || `Stub Output ${index}`;
  }

  openPort(index) {
    this._port = index;
    this._name = this.getPortName(index);
    this._virtual = false;
    this._isOpen = true;
  }

  openVirtualPort(name) {
    this._name = name || this._name;
    this._virtual = true;
    this._virtualOpen = true;
    this._isOpen = true;
  }

  sendMessage(_msg) {
    // no-op; stub does not route MIDI anywhere
  }
}

module.exports = {
  input: StubInput,
  output: StubOutput,
};
