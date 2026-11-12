// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            AB: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      AC: Function.prototype.call.bind(DataView.prototype.setUint16),
      AD: x0 => x0.width,
      AE: x0 => new ResizeObserver(x0),
      AF: x0 => x0.key,
      AG: x0 => x0.current(),
      AH: (x0,x1) => { x0.value = x1 },
      AI: x0 => x0.disabled,
      AJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      AK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      AL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      AM: (x0,x1,x2) => x0.sqlite3_column_type(x1,x2),
      AN: () => globalThis.navigator,
      AO: () => globalThis.indexedDB,
      AP: x0 => new Blob(x0),
      AQ: x0 => x0.permissions,
      B: s => printToConsole(s),
      BB: b => !!b,
      BC: Function.prototype.call.bind(DataView.prototype.setUint8),
      BD: x0 => x0.screen,
      BE: (x0,x1) => x0.getPropertyValue(x1),
      BF: x0 => x0.identifier,
      BG: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      BH: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      BI: (x0,x1) => { x0.min = x1 },
      BJ: (x0,x1) => { x0.onerror = x1 },
      BK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      BL: (x0,x1) => x0.postMessage(x1),
      BM: (x0,x1) => x0.sqlite3_column_count(x1),
      BN: x0 => new URL(x0),
      BO: (x0,x1) => ({name: x0,length: x1}),
      BP: x0 => x0.close(),
      BQ: x0 => x0.geolocation,
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      CC: Function.prototype.call.bind(DataView.prototype.setInt8),
      CD: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      CE: x0 => globalThis.parseFloat(x0),
      CF: x0 => x0.touches,
      CG: x0 => x0.v8BreakIterator,
      CH: (x0,x1) => { x0.value = x1 },
      CI: (x0,x1) => { x0.max = x1 },
      CJ: x0 => x0.error,
      CK: x0 => x0.openCursor(),
      CL: x0 => x0.close(),
      CM: (x0,x1,x2,x3,x4,x5) => x0.dart_sqlite3_create_scalar_function(x1,x2,x3,x4,x5),
      CN: (x0,x1) => new URL(x0,x1),
      CO: (x0,x1) => x0.update(x1),
      CP: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      CQ: x0 => x0.mediaDevices,
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: (x0,x1) => x0.focus(x1),
      DC: Function.prototype.call.bind(DataView.prototype.getInt8),
      DD: x0 => x0.tabIndex,
      DE: (x0,x1) => x0.getComputedStyle(x1),
      DF: x0 => x0.pressure,
      DG: () => globalThis.Intl,
      DH: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      DI: (x0,x1) => { x0.disabled = x1 },
      DJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      DK: (x0,x1) => x0.openCursor(x1),
      DL: (x0,x1) => ({i: x0,p: x1}),
      DM: (x0,x1,x2,x3) => x0.sqlite3_result_error(x1,x2,x3),
      DN: (x0,x1) => globalThis.fetch(x0,x1),
      DO: x0 => x0.name,
      DP: (x0,x1) => x0.decode(x1),
      DQ: x0 => x0.baseURI,
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: () => ({}),
      EC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      ED: (x0,x1) => x0.contains(x1),
      EE: x0 => x0.documentElement,
      EF: x0 => x0.tiltY,
      EG: (x0,x1) => x0.segment(x1),
      EH: x0 => x0.value,
      EI: (x0,x1) => { x0.scrollLeft = x1 },
      EJ: (x0,x1) => { x0.onsuccess = x1 },
      EK: x0 => x0.indexedDB,
      EL: () => new Array(),
      EM: x0 => x0.sqlite3_result_subtype,
      EN: x0 => x0.exports,
      EO: x0 => globalThis.IDBKeyRange.only(x0),
      EP: x0 => x0.displayHeight,
      EQ: x0 => x0.document,
      F: () => new Error().stack,
      FB: (o, p, v) => o[p] = v,
      FC: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      FD: x0 => x0.activeElement,
      FE: x0 => x0.computedStyleMap(),
      FF: x0 => x0.tiltX,
      FG: x0 => x0.index,
      FH: x0 => x0.selectionDirection,
      FI: (x0,x1) => { x0.spellcheck = x1 },
      FJ: x0 => x0.result,
      FK: () => new XMLHttpRequest(),
      FL: (x0,x1) => ({c: x0,r: x1}),
      FM: (x0,x1,x2,x3,x4) => x0.sqlite3_result_blob64(x1,x2,x3,x4),
      FN: (x0,x1) => globalThis.WebAssembly.instantiateStreaming(x0,x1),
      FO: x0 => x0.port2,
      FP: x0 => x0.displayWidth,
      FQ: x0 => x0.abort(),
      G: s => JSON.stringify(s),
      GB: () => [],
      GC: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      GD: x0 => x0.parentNode,
      GE: (x0,x1) => x0.get(x1),
      GF: x0 => x0.pointerType,
      GG: x0 => x0.next(),
      GH: x0 => x0.selectionStart,
      GI: (x0,x1) => { x0.disabled = x1 },
      GJ: x0 => new Date(x0),
      GK: (x0,x1,x2) => x0.open(x1,x2),
      GL: (x0,x1) => { x0.onmessage = x1 },
      GM: (x0,x1,x2,x3,x4) => x0.sqlite3_result_text(x1,x2,x3,x4),
      GN: x0 => x0.call(),
      GO: (x0,x1) => x0.deleteDatabase(x1),
      GP: x0 => x0.duration,
      GQ: () => globalThis.Intl.supportedValuesOf,
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: (a, i) => a.push(i),
      HC: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      HD: x0 => x0.tagName,
      HE: (o, p) => p in o,
      HF: x0 => x0.pointerId,
      HG: x0 => x0.value,
      HH: x0 => x0.selectionEnd,
      HI: (a, i) => a.splice(i, 1),
      HJ: (o, p, v) => o[p] = v,
      HK: (x0,x1) => x0.send(x1),
      HL: (o, a) => o == a,
      HM: (x0,x1,x2) => x0.sqlite3_result_double(x1,x2),
      HN: x0 => x0.instance,
      HO: x0 => x0.terminate(),
      HP: x0 => x0.image,
      HQ: () => globalThis.Intl.DateTimeFormat(),
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: x0 => new Int8Array(x0),
      IC: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      ID: x0 => x0.target,
      IE: (x0,x1) => { x0.textContent = x1 },
      IF: x0 => x0.getCoalescedEvents(),
      IG: x0 => x0.done,
      IH: x0 => x0.value,
      II: a => a.pop(),
      IJ: (x0,x1) => x0.getKey(x1),
      IK: x0 => x0.send(),
      IL: x0 => x0.r,
      IM: (x0,x1,x2) => x0.sqlite3_result_int64(x1,x2),
      IN: x0 => ({initial: x0}),
      IO: (x0,x1) => new SharedWorker(x0,x1),
      IP: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      IQ: x0 => x0.resolvedOptions(),
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      JC: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      JD: x0 => x0.clientY,
      JE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      JF: (x0,x1) => x0.getModifierState(x1),
      JG: (o, m, a) => o[m].apply(o, a),
      JH: x0 => x0.selectionDirection,
      JI: (map, o, v) => map.set(o, v),
      JJ: (x0,x1) => x0.get(x1),
      JK: x0 => x0.abort(),
      JL: x0 => x0.c,
      JM: (x0,x1) => x0.sqlite3_result_null(x1),
      JN: x0 => new WebAssembly.Memory(x0),
      JO: x0 => x0.port,
      JP: x0 => new window.ImageDecoder(x0),
      JQ: x0 => x0.timeZone,
      K: o => o,
      KB: x0 => new Uint8Array(x0),
      KC: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      KD: x0 => x0.clientX,
      KE: x0 => x0.matches,
      KF: s => s.trimLeft(),
      KG: x0 => x0.iterator,
      KH: x0 => x0.selectionStart,
      KI: (map, o) => map.get(o),
      KJ: (x0,x1) => x0.index(x1),
      KK: x0 => x0.upload,
      KL: x0 => x0.p,
      KM: (x0,x1) => x0.sqlite3_value_blob(x1),
      KN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      KO: x0 => ({type: x0}),
      KP: x0 => x0.name,
      KQ: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      L: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      LB: x0 => new Uint8ClampedArray(x0),
      LC: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      LD: (x0,x1,x2) => x0.setAttribute(x1,x2),
      LE: (x0,x1) => x0.matchMedia(x1),
      LF: s => s.toUpperCase(),
      LG: () => globalThis.Symbol,
      LH: x0 => x0.selectionEnd,
      LI: () => new WeakMap(),
      LJ: x0 => x0.multiEntry,
      LK: x0 => x0.readyState,
      LL: x0 => x0.i,
      LM: (x0,x1) => x0.sqlite3_value_bytes(x1),
      LN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return wasmFunction(f,arguments.length,x0,x1,x2,x3,x4) }),
      LO: (x0,x1) => new Blob(x0,x1),
      LP: x0 => x0.repetitionCount,
      LQ: (x0,x1) => { x0.nativeCommunication = x1 },
      M: x0 => x0.index,
      MB: x0 => new Int16Array(x0),
      MC: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      MD: x0 => x0.getBoundingClientRect(),
      ME: x0 => x0.matches,
      MF: x0 => x0.pop(),
      MG: (x0,x1) => new Intl.Segmenter(x0,x1),
      MH: x0 => x0.keyCode,
      MI: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      MJ: x0 => x0.unique,
      MK: x0 => x0.responseURL,
      ML: (x0,x1,x2) => x0.postMessage(x1,x2),
      MM: (x0,x1) => x0.sqlite3_value_text(x1),
      MN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      MO: () => new FileReader(),
      MP: x0 => x0.frameCount,
      MQ: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      N: o => String(o),
      NB: x0 => new Uint16Array(x0),
      NC: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      ND: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      NE: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      NF: x0 => x0.flags,
      NG: x0 => x0.Segmenter,
      NH: (x0,x1) => x0.scrollIntoView(x1),
      NI: (a, s, e) => a.slice(s, e),
      NJ: x0 => x0.keyPath,
      NK: x0 => x0.statusText,
      NL: x0 => x0.port1,
      NM: (x0,x1) => x0.sqlite3_value_double(x1),
      NN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2,x3) { return wasmFunction(f,arguments.length,x0,x1,x2,x3) }),
      NO: (x0,x1) => x0.readAsArrayBuffer(x1),
      NP: x0 => x0.selectedTrack,
      NQ: (o,s,v) => o[s] = v,
      O: o => o === undefined,
      OB: x0 => new Int32Array(x0),
      OC: (x0,x1) => x0.querySelector(x1),
      OD: s => new Date(s * 1000).getTimezoneOffset() * 60,
      OE: f => f.dartFunction,
      OF: (a, s) => a.join(s),
      OG: x0 => x0.buffer,
      OH: x0 => x0.multiViewEnabled,
      OI: x0 => new WeakRef(x0),
      OJ: x0 => x0.name,
      OK: x0 => x0.getAllResponseHeaders(),
      OL: (x0,x1) => x0.sqlite3_finalize(x1),
      OM: (x0,x1) => x0.sqlite3_value_int64(x1),
      ON: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2,x3) { return wasmFunction(f,arguments.length,x0,x1,x2,x3) }),
      OO: x0 => x0.result,
      OP: x0 => x0.completed,
      OQ: () => Symbol("jsBoxedDartObjectProperty"),
      P: (x0,x1) => x0.exec(x1),
      PB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      PC: (x0,x1) => x0.item(x1),
      PD: Date.now,
      PE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PF: (x0,x1) => x0.error(x1),
      PG: x0 => x0.wasmMemory,
      PH: (x0,x1) => x0.replaceWith(x1),
      PI: x0 => x0.deref(),
      PJ: (x0,x1) => x0.objectStore(x1),
      PK: x0 => x0.status,
      PL: (x0,x1) => x0.dart_sqlite3_free(x1),
      PM: (x0,x1) => x0.sqlite3_value_type(x1),
      PN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      PO: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      PP: x0 => x0.ready,
      PQ: () => globalThis.window.flutter_inappwebview,
      Q: (x0,x1) => { x0.lastIndex = x1 },
      QB: x0 => new Uint32Array(x0),
      QC: x0 => x0.length,
      QD: (handle) => clearTimeout(handle),
      QE: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      QF: () => globalThis.console,
      QG: () => globalThis.window._flutter_skwasmInstance,
      QH: (x0,x1) => { x0.type = x1 },
      QI: () => globalThis.WeakRef,
      QJ: x0 => x0.autoIncrement,
      QK: x0 => x0.response,
      QL: (x0,x1) => x0.sqlite3_reset(x1),
      QM: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      QN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      QO: x0 => x0.type,
      QP: x0 => x0.tracks,
      QQ: (x0,x1) => { x0.src = x1 },
      R: o => o,
      RB: x0 => new Float32Array(x0),
      RC: (x0,x1) => x0.querySelectorAll(x1),
      RD: (x0,x1) => x0.closest(x1),
      RE: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      RF: s => s.trimRight(),
      RG: () => new TextDecoder(),
      RH: (x0,x1) => { x0.className = x1 },
      RI: (o, p) => p in o,
      RJ: x0 => x0.keyPath,
      RK: x0 => x0.withCredentials,
      RL: (x0,x1) => x0.unregister(x1),
      RM: (x0,x1,x2) => x0.sqlite3_extended_result_codes(x1,x2),
      RN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      RO: x0 => x0.vendor,
      RP: () => globalThis.window.ImageDecoder,
      RQ: (x0,x1) => x0.getResponseHeader(x1),
      S: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      SB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      SC: (x0,x1) => x0.getAttribute(x1),
      SD: x0 => x0.bottom,
      SE: (o, i) => o[i],
      SF: x0 => x0.blur(),
      SG: (d, digits) => d.toFixed(digits),
      SH: (x0,x1) => { x0.tabIndex = x1 },
      SI: x0 => x0.groups,
      SJ: x0 => x0.name,
      SK: (x0,x1) => { x0.timeout = x1 },
      SL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      SM: (x0,x1,x2,x3,x4) => x0.sqlite3_open_v2(x1,x2,x3,x4),
      SN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      SO: x0 => x0.navigator,
      SP: (x0,x1) => x0.get(x1),
      SQ: x0 => x0.responseText,
      T: o => o instanceof RegExp,
      TB: x0 => new Float64Array(x0),
      TC: x0 => x0.remove(),
      TD: x0 => x0.top,
      TE: o => o.length,
      TF: x0 => x0.button,
      TG: x0 => x0.maxHeight,
      TH: (x0,x1) => { x0.name = x1 },
      TI: (x0,x1) => x0.getRandomValues(x1),
      TJ: (x0,x1) => x0.item(x1),
      TK: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      TL: x0 => new FinalizationRegistry(x0),
      TM: (x0,x1) => x0.call(x1),
      TN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      TO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      TP: x0 => x0.body,
      TQ: (x0,x1) => x0.append(x1),
      U: (string, times) => string.repeat(times),
      UB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      UC: (x0,x1) => x0.appendChild(x1),
      UD: x0 => x0.right,
      UE: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      UF: x0 => x0.innerHeight,
      UG: x0 => x0.maxWidth,
      UH: (x0,x1) => { x0.placeholder = x1 },
      UI: () => globalThis.crypto,
      UJ: x0 => x0.length,
      UK: (x0,x1) => { x0.withCredentials = x1 },
      UL: () => globalThis.FinalizationRegistry,
      UM: x0 => x0.sqlite3_initialize,
      UN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2,x3) { return wasmFunction(f,arguments.length,x0,x1,x2,x3) }),
      UO: (x0,x1,x2) => x0.addEventListener(x1,x2),
      UP: x0 => x0.headers,
      UQ: (x0,x1,x2) => x0.setAttribute(x1,x2),
      V: o => o,
      VB: x0 => new ArrayBuffer(x0),
      VC: (x0,x1) => x0.append(x1),
      VD: x0 => x0.left,
      VE: x0 => x0.language,
      VF: x0 => x0.innerWidth,
      VG: x0 => x0.minHeight,
      VH: (x0,x1) => { x0.autocomplete = x1 },
      VI: l => new DataView(new ArrayBuffer(l)),
      VJ: x0 => x0.objectStoreNames,
      VK: (x0,x1) => { x0.responseType = x1 },
      VL: x0 => x0.buffer,
      VM: (x0,x1,x2,x3) => x0.dart_sqlite3_register_vfs(x1,x2,x3),
      VN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2,x3) { return wasmFunction(f,arguments.length,x0,x1,x2,x3) }),
      VO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      VP: (x0,x1) => x0.transferFromImageBitmap(x1),
      VQ: (x0,x1) => x0.removeAttribute(x1),
      W: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      WB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      WC: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      WD: x0 => x0.clientY,
      WE: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      WF: x0 => x0.height,
      WG: x0 => x0.minWidth,
      WH: (x0,x1) => { x0.name = x1 },
      WI: (x0,x1,x2) => x0.setItem(x1,x2),
      WJ: (x0,x1,x2) => x0.transaction(x1,x2),
      WK: (x0,x1) => x0.getItem(x1),
      WL: (x0,x1) => x0.sqlite3_errstr(x1),
      WM: (x0,x1) => globalThis.Atomics.load(x0,x1),
      WN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      WO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      WP: (x0,x1) => x0.getContext(x1),
      WQ: (x0,x1) => { x0.csp = x1 },
      X: x0 => x0.dotAll,
      XB: (x0,x1,x2) => new DataView(x0,x1,x2),
      XC: x0 => x0.style,
      XD: x0 => x0.clientX,
      XE: () => globalThis.window.FinalizationRegistry,
      XF: x0 => x0.width,
      XG: x0 => x0.debugSkipFontRetryDelay,
      XH: (x0,x1) => { x0.placeholder = x1 },
      XI: x0 => x0.localStorage,
      XJ: (x0,x1,x2) => x0.open(x1,x2),
      XK: (x0,x1) => x0.key(x1),
      XL: (x0,x1) => x0.sqlite3_errmsg(x1),
      XM: (x0,x1,x2) => globalThis.Atomics.wait(x0,x1,x2),
      XN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      XO: (x0,x1) => x0.removeChild(x1),
      XP: (x0,x1) => { x0.height = x1 },
      XQ: x0 => x0.csp,
      Y: x0 => x0.unicode,
      YB: (o, p) => o[p],
      YC: x0 => x0.debugShowSemanticsNodes,
      YD: x0 => x0.changedTouches,
      YE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      YF: x0 => x0.clientHeight,
      YG: x0 => x0.status,
      YH: (x0,x1) => { x0.action = x1 },
      YI: () => globalThis.window,
      YJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      YK: x0 => x0.length,
      YL: x0 => x0.sqlite3_error_offset,
      YM: (x0,x1,x2) => globalThis.Atomics.notify(x0,x1,x2),
      YN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      YO: (o, a) => o + a,
      YP: (x0,x1) => { x0.width = x1 },
      YQ: (x0,x1) => { x0.name = x1 },
      Z: x0 => x0.ignoreCase,
      ZB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      ZC: (x0,x1) => x0.warn(x1),
      ZD: x0 => x0.offsetY,
      ZE: x0 => new window.FinalizationRegistry(x0),
      ZF: x0 => x0.clientWidth,
      ZG: (x0,x1,x2) => x0.set(x1,x2),
      ZH: (x0,x1) => { x0.method = x1 },
      ZI: x0 => new Blob(x0),
      ZJ: x0 => x0.close(),
      ZK: () => new AbortController(),
      ZL: (x0,x1) => x0.sqlite3_extended_errcode(x1),
      ZM: (x0,x1,x2) => globalThis.Atomics.store(x0,x1,x2),
      ZN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      ZO: x0 => x0.children,
      ZP: x0 => x0.height,
      ZQ: x0 => x0.name,
      a: x0 => x0.multiline,
      aB: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      aC: x0 => x0.console,
      aD: x0 => x0.offsetX,
      aE: (x0,x1) => x0.unregister(x1),
      aF: (x0,x1) => { x0.content = x1 },
      aG: x0 => x0.arrayBuffer(),
      aH: (x0,x1) => { x0.noValidate = x1 },
      aI: x0 => globalThis.URL.createObjectURL(x0),
      aJ: x0 => x0.name,
      aK: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      aL: (x0,x1) => x0.sqlite3_step(x1),
      aM: x0 => new Worker(x0),
      aN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      aO: x0 => x0.firstChild,
      aP: x0 => x0.width,
      aQ: (x0,x1) => { x0.referrerPolicy = x1 },
      b: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      bB: o => o.byteOffset,
      bC: () => globalThis.window,
      bD: x0 => x0.type,
      bE: (x0,x1) => x0.contains(x1),
      bF: (x0,x1) => { x0.name = x1 },
      bG: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      bH: (x0,x1) => x0.removeAttribute(x1),
      bI: x0 => x0.click(),
      bJ: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      bK: (x0,x1) => globalThis.fetch(x0,x1),
      bL: (x0,x1,x2,x3,x4,x5) => x0.sqlite3_bind_blob64(x1,x2,x3,x4,x5),
      bM: () => globalThis.Uint8Array,
      bN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      bO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      bP: x0 => x0.rasterEndMilliseconds,
      bQ: x0 => x0.referrerPolicy,
      c: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      cB: o => o.buffer,
      cC: (o, c) => o instanceof c,
      cD: x0 => x0.maxTouchPoints,
      cE: (s) => +s,
      cF: x0 => x0.head,
      cG: (x0,x1) => x0.fetch(x1),
      cH: x0 => x0.isConnected,
      cI: x0 => globalThis.URL.revokeObjectURL(x0),
      cJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      cK: (x0,x1) => x0.get(x1),
      cL: x0 => globalThis.BigInt(x0),
      cM: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof DataView) return 1;
        return 2;
      },
      cN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      cO: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      cP: x0 => x0.rasterStartMilliseconds,
      cQ: (x0,x1) => { x0.allowFullscreen = x1 },
      d: (x0,x1) => x0.didCreateEngineInitializer(x1),
      dB: Function.prototype.call.bind(DataView.prototype.getUint8),
      dC: (x0,x1) => x0[x1],
      dD: x0 => x0.platform,
      dE: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      dF: (x0,x1) => x0.removeChild(x1),
      dG: x0 => x0.fontFallbackBaseUrl,
      dH: x0 => x0.click(),
      dI: (x0,x1) => { x0.download = x1 },
      dJ: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      dK: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      dL: (x0,x1) => x0.dart_sqlite3_malloc(x1),
      dM: () => globalThis.DataView,
      dN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      dO: (x0,x1) => x0.item(x1),
      dP: x0 => x0.imageBitmaps,
      dQ: x0 => x0.allowFullscreen,
      e: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      eB: (b, o) => new DataView(b, o),
      eC: x0 => x0.length,
      eD: x0 => x0.body,
      eE: s => s.trim(),
      eF: x0 => x0.firstChild,
      eG: (handle) => clearInterval(handle),
      eH: (x0,x1) => x0.getElementsByClassName(x1),
      eI: (x0,x1) => { x0.target = x1 },
      eJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      eK: (x0,x1) => x0.forEach(x1),
      eL: (x0,x1,x2,x3,x4,x5) => x0.sqlite3_bind_text(x1,x2,x3,x4,x5),
      eM: x0 => x0.communicationBuffer,
      eN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      eO: x0 => x0.size,
      eP: x0 => x0.canvasKitMaximumSurfaces,
      eQ: (x0,x1) => { x0.allow = x1 },
      f: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      fB: (b, o, l) => new DataView(b, o, l),
      fC: (string, token) => string.split(token),
      fD: () => globalThis.document,
      fE: x0 => x0.classList,
      fF: x0 => x0.viewConstraints,
      fG: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      fH: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      fI: (x0,x1) => { x0.href = x1 },
      fJ: (x0,x1) => ({unique: x0,multiEntry: x1}),
      fK: x0 => x0.statusText,
      fL: (x0,x1,x2,x3) => x0.sqlite3_bind_double(x1,x2,x3),
      fM: () => globalThis.Int32Array,
      fN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fO: x0 => x0.name,
      fP: x0 => x0.hostElement,
      fQ: x0 => x0.allow,
      g: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      gB: Function.prototype.call.bind(DataView.prototype.getFloat64),
      gC: o => o instanceof Array,
      gD: (x0,x1,x2) => x0.addEventListener(x1,x2),
      gE: x0 => x0.preventDefault(),
      gF: x0 => x0.hostElement,
      gG: () => Date.now(),
      gH: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      gI: (x0,x1) => x0.createElement(x1),
      gJ: (x0,x1,x2,x3) => x0.createIndex(x1,x2,x3),
      gK: x0 => x0.url,
      gL: (x0,x1,x2,x3) => x0.sqlite3_bind_int64(x1,x2,x3),
      gM: x0 => x0.byteLength,
      gN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gO: x0 => x0.type,
      gP: x0 => x0.location,
      gQ: (x0,x1) => { x0.height = x1 },
      h: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      hB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      hC: (a, i) => a[i],
      hD: x0 => x0.hasFocus(),
      hE: x0 => x0.parent,
      hF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      hG: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      hH: (x0,x1) => x0.dispatchEvent(x1),
      hI: () => globalThis.document,
      hJ: (x0,x1) => ({keyPath: x0,autoIncrement: x1}),
      hK: x0 => x0.status,
      hL: (x0,x1,x2) => x0.sqlite3_bind_null(x1,x2),
      hM: x0 => x0.synchronizationBuffer,
      hN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      hO: (x0,x1,x2) => x0.slice(x1,x2),
      hP: (x0,x1) => x0.getModifierState(x1),
      hQ: (x0,x1) => { x0.width = x1 },
      i: x0 => new Promise(x0),
      iB: Function.prototype.call.bind(DataView.prototype.setFloat64),
      iC: a => a.length,
      iD: x0 => x0.relatedTarget,
      iE: x0 => x0.timeStamp,
      iF: x0 => ({runApp: x0}),
      iG: x0 => x0.history,
      iH: (x0,x1) => x0.createEvent(x1),
      iI: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      iJ: (x0,x1,x2) => x0.createObjectStore(x1,x2),
      iK: x0 => x0.getReader(),
      iL: (x0,x1) => x0.sqlite3_bind_parameter_count(x1),
      iM: (x0,x1,x2) => x0.postMessage(x1,x2),
      iN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return wasmFunction(f,arguments.length,x0,x1,x2,x3,x4) }),
      iO: x0 => x0.length,
      iP: x0 => x0.metaKey,
      iQ: x0 => x0.src,
      j: (x0,x1,x2) => x0.call(x1,x2),
      jB: (t, s) => t.set(s),
      jC: (x0,x1) => x0.test(x1),
      jD: x0 => x0.shiftKey,
      jE: (x0,x1) => x0.hasAttribute(x1),
      jF: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      jG: x0 => x0.search,
      jH: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      jI: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      jJ: (x0,x1) => x0.deleteObjectStore(x1),
      jK: x0 => x0.read(),
      jL: (x0,x1) => x0.sqlite3_stmt_isexplain(x1),
      jM: x0 => new SharedArrayBuffer(x0),
      jN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return wasmFunction(f,arguments.length,x0,x1,x2,x3,x4) }),
      jO: x0 => x0.files,
      jP: x0 => x0.altKey,
      jQ: (x0,x1) => x0.item(x1),
      k: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      kB: Function.prototype.call.bind(DataView.prototype.setFloat32),
      kC: x0 => x0.userAgent,
      kD: (decoder, codeUnits) => decoder.decode(codeUnits),
      kE: x0 => x0.buttons,
      kF: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      kG: x0 => x0.location,
      kH: x0 => x0.readText(),
      kI: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      kJ: x0 => x0.oldVersion,
      kK: x0 => x0.value,
      kL: (x0,x1,x2,x3,x4,x5,x6) => x0.sqlite3_prepare_v3(x1,x2,x3,x4,x5,x6),
      kM: (x0,x1,x2,x3) => ({clientVersion: x0,root: x1,synchronizationBuffer: x2,communicationBuffer: x3}),
      kN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      kO: (x0,x1) => { x0.display = x1 },
      kP: x0 => x0.ctrlKey,
      kQ: x0 => x0.length,
      l: x0 => new Array(x0),
      lB: Function.prototype.call.bind(DataView.prototype.getFloat32),
      lC: x0 => x0.navigator,
      lD: () => new TextDecoder("utf-8", {fatal: true}),
      lE: x0 => x0.ctrlKey,
      lF: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      lG: x0 => x0.pathname,
      lH: x0 => x0.clipboard,
      lI: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      lJ: x0 => x0.target,
      lK: x0 => x0.done,
      lL: (x0,x1,x2,x3,x4,x5) => x0.sqlite3_exec(x1,x2,x3,x4,x5),
      lM: x0 => x0.close(),
      lN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      lO: x0 => x0.style,
      lP: x0 => x0.isComposing,
      lQ: x0 => x0.sandbox,
      m: o => [o],
      mB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      mC: Function.prototype.call.bind(String.prototype.toLowerCase),
      mD: () => new TextDecoder("utf-8", {fatal: false}),
      mE: x0 => x0.y,
      mF: o => o.byteLength,
      mG: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      mH: (x0,x1) => x0.writeText(x1),
      mI: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      mJ: (x0,x1) => { x0.onblocked = x1 },
      mK: x0 => x0.cancel(),
      mL: (x0,x1) => x0.sqlite3_close_v2(x1),
      mM: (x0,x1) => x0.truncate(x1),
      mN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      mO: (x0,x1) => { x0.accept = x1 },
      mP: x0 => x0.code,
      mQ: x0 => x0.id,
      n: (o0, o1) => [o0, o1],
      nB: Function.prototype.call.bind(DataView.prototype.getUint32),
      nC: Object.is,
      nD: (a, i, v) => a[i] = v,
      nE: x0 => x0.x,
      nF: () => typeof dartUseDateNowForTicks !== "undefined",
      nG: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      nH: x0 => x0.unlock(),
      nI: (x0,x1) => { x0.oncomplete = x1 },
      nJ: (x0,x1) => x0.delete(x1),
      nK: x0 => x0.body,
      nL: (x0,x1,x2,x3) => x0.call(x1,x2,x3),
      nM: x0 => ({at: x0}),
      nN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      nO: (x0,x1) => { x0.multiple = x1 },
      nP: x0 => x0.repeat,
      nQ: (x0,x1) => { x0.border = x1 },
      o: (o0, o1, o2) => [o0, o1, o2],
      oB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      oC: x0 => x0.vendor,
      oD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      oE: x0 => x0.scrollTop,
      oF: () => Date.now(),
      oG: o => Object.keys(o),
      oH: (x0,x1) => x0.lock(x1),
      oI: (x0,x1) => { x0.onabort = x1 },
      oJ: (x0,x1,x2,x3) => globalThis.IDBKeyRange.bound(x0,x1,x2,x3),
      oK: x0 => x0.headers,
      oL: x0 => x0.dart_sqlite3_rollbacks,
      oM: x0 => x0.flush(),
      oN: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      oO: (x0,x1) => { x0.draggable = x1 },
      oP: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      oQ: (x0,x1) => { x0.id = x1 },
      p: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      pB: Function.prototype.call.bind(DataView.prototype.getInt32),
      pC: (x0,x1) => x0.createTextNode(x1),
      pD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      pE: x0 => x0.offsetTop,
      pF: () => 1000 * performance.now(),
      pG: x0 => x0.state,
      pH: x0 => x0.orientation,
      pI: (x0,x1) => { x0.onerror = x1 },
      pJ: (x0,x1) => x0.put(x1),
      pK: x0 => x0.signal,
      pL: x0 => x0.dart_sqlite3_commits,
      pM: (x0,x1) => x0.write(x1),
      pN: (x0,x1) => x0.sqlite3_user_data(x1),
      pO: (x0,x1) => { x0.type = x1 },
      pP: x0 => x0.userAgent,
      pQ: (x0,x1) => x0.getCookieExpirationDate(x1),
      q: (x0,x1,x2) => { x0[x1] = x2 },
      qB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      qC: (x0,x1) => { x0.id = x1 },
      qD: x0 => x0.visibilityState,
      qE: x0 => x0.scrollLeft,
      qF: (x0,x1) => x0.requestAnimationFrame(x1),
      qG: x0 => x0.hash,
      qH: (x0,x1) => x0.querySelector(x1),
      qI: x0 => x0.message,
      qJ: (x0,x1,x2) => x0.put(x1,x2),
      qK: () => new MessageChannel(),
      qL: x0 => x0.dart_sqlite3_updates,
      qM: (x0,x1,x2) => x0.write(x1,x2),
      qN: x0 => x0.getSize(),
      qO: (x0,x1) => x0.revokeObjectURL(x1),
      qP: (x0,x1) => x0.canShare(x1),
      qQ: (x0,x1) => x0.querySelector(x1),
      r: (o, p) => o[p],
      rB: o => o instanceof Uint16Array,
      rC: (x0,x1) => { x0.nonce = x1 },
      rD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      rE: x0 => x0.offsetLeft,
      rF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      rG: x0 => x0.state,
      rH: (x0,x1) => { x0.title = x1 },
      rI: x0 => x0.name,
      rJ: (x0,x1) => x0.get(x1),
      rK: x0 => x0.start(),
      rL: (x0,x1) => x0.sqlite3_last_insert_rowid(x1),
      rM: (x0,x1) => x0.read(x1),
      rN: x0 => x0.arrayBuffer(),
      rO: (x0,x1) => { x0.src = x1 },
      rP: (x0,x1) => x0.share(x1),
      rQ: x0 => x0.length,
      s: () => globalThis,
      sB: Function.prototype.call.bind(DataView.prototype.getUint16),
      sC: x0 => x0.nonce,
      sD: x0 => x0.disconnect(),
      sE: x0 => x0.offsetParent,
      sF: x0 => x0.now(),
      sG: (x0,x1) => x0.go(x1),
      sH: (x0,x1) => x0.vibrate(x1),
      sI: x0 => x0.error,
      sJ: (x0,x1) => x0.openKeyCursor(x1),
      sK: x0 => new BroadcastChannel(x0),
      sL: x0 => globalThis.Number(x0),
      sM: (x0,x1,x2) => x0.read(x1,x2),
      sN: (x0,x1) => globalThis.IDBKeyRange.bound(x0,x1),
      sO: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      sP: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      sQ: x0 => x0.getReader(),
      t: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      tB: o => o instanceof Int16Array,
      tC: () => globalThis.window.flutterConfiguration,
      tD: x0 => new Intl.Locale(x0),
      tE: (o, p, r) => o.replace(p, () => r),
      tF: x0 => x0.performance,
      tG: x0 => x0.parentElement,
      tH: x0 => x0.content,
      tI: x0 => x0.message,
      tJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      tK: x0 => globalThis.Array.isArray(x0),
      tL: (x0,x1) => x0.sqlite3_changes(x1),
      tM: x0 => x0.createSyncAccessHandle(),
      tN: x0 => x0.length,
      tO: x0 => x0.naturalHeight,
      tP: x0 => x0.remove(),
      tQ: x0 => x0.value,
      u: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      uB: Function.prototype.call.bind(DataView.prototype.getInt16),
      uC: (x0,x1) => x0.attachShadow(x1),
      uD: x0 => x0.region,
      uE: (o, p, r) => o.replaceAll(p, () => r),
      uF: x0 => new Uint8Array(x0),
      uG: (x0,x1) => x0.querySelectorAll(x1),
      uH: x0 => x0.document,
      uI: x0 => x0.name,
      uJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      uK: x0 => x0.table,
      uL: (x0,x1,x2) => x0.sqlite3_column_name(x1,x2),
      uM: x0 => ({create: x0}),
      uN: x0 => x0.openKeyCursor(),
      uO: x0 => x0.naturalWidth,
      uP: x0 => x0.body,
      uQ: x0 => x0.done,
      v: (x0,x1) => ({addView: x0,removeView: x1}),
      vB: o => o instanceof Uint8ClampedArray,
      vC: (x0,x1) => x0.createElement(x1),
      vD: x0 => x0.script,
      vE: x0 => x0.deltaMode,
      vF: (x0,x1,x2) => x0.slice(x1,x2),
      vG: (x0,x1) => x0.removeProperty(x1),
      vH: (x0,x1,x2) => x0.insertBefore(x1,x2),
      vI: (x0,x1) => x0.add(x1),
      vJ: x0 => x0.continue(),
      vK: x0 => x0.kind,
      vL: (x0,x1,x2) => x0.sqlite3_column_blob(x1,x2),
      vM: (x0,x1,x2) => x0.getFileHandle(x1,x2),
      vN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      vO: x0 => x0.decode(),
      vP: x0 => ({url: x0}),
      vQ: x0 => x0.read(),
      w: (l, r) => l === r,
      wB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      wC: x0 => x0.scale,
      wD: x0 => x0.language,
      wE: x0 => x0.deltaY,
      wF: (x0,x1) => x0.decode(x1),
      wG: (x0,x1) => x0.add(x1),
      wH: x0 => x0.id,
      wI: x0 => x0.getTime(),
      wJ: x0 => x0.primaryKey,
      wK: x0 => x0.data,
      wL: (x0,x1,x2) => x0.sqlite3_column_bytes(x1,x2),
      wM: x0 => ({create: x0}),
      wN: (x0,x1) => { x0.onupgradeneeded = x1 },
      wO: (x0,x1) => { x0.decoding = x1 },
      wP: x0 => ({files: x0}),
      wQ: (x0,x1) => new OffscreenCanvas(x0,x1),
      x: x0 => x0.random(),
      xB: Function.prototype.call.bind(DataView.prototype.setInt32),
      xC: x0 => x0.visualViewport,
      xD: x0 => x0.languages,
      xE: x0 => x0.deltaX,
      xF: (x0,x1) => x0.adoptText(x1),
      xG: x0 => x0.data,
      xH: x0 => x0.offsetHeight,
      xI: x0 => globalThis.Object.keys(x0),
      xJ: x0 => x0.key,
      xK: x0 => x0.close(),
      xL: (x0,x1,x2) => x0.sqlite3_column_text(x1,x2),
      xM: (x0,x1,x2) => x0.getDirectoryHandle(x1,x2),
      xN: x0 => ({autoIncrement: x0}),
      xO: (x0,x1) => { x0.crossOrigin = x1 },
      xP: () => ({}),
      xQ: x0 => x0.assetBase,
      y: () => globalThis.Math,
      yB: Function.prototype.call.bind(DataView.prototype.setUint32),
      yC: x0 => x0.devicePixelRatio,
      yD: (x0,x1) => x0.observe(x1),
      yE: x0 => x0.wheelDeltaY,
      yF: x0 => x0.first(),
      yG: (x0,x1) => { x0.scrollTop = x1 },
      yH: x0 => x0.offsetWidth,
      yI: x0 => x0.length,
      yJ: x0 => x0.value,
      yK: (x0,x1) => x0.postMessage(x1),
      yL: (x0,x1,x2) => x0.sqlite3_column_double(x1,x2),
      yM: x0 => x0.getDirectory(),
      yN: x0 => ({unique: x0}),
      yO: (x0,x1) => x0.createObjectURL(x1),
      yP: (x0,x1,x2) => new File(x0,x1,x2),
      yQ: x0 => x0.loader,
      z: (x0,x1) => x0.prepend(x1),
      zB: Function.prototype.call.bind(DataView.prototype.setInt16),
      zC: x0 => x0.height,
      zD: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      zE: x0 => x0.wheelDeltaX,
      zF: x0 => x0.next(),
      zG: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      zH: x0 => x0.stopPropagation(),
      zI: (o, t) => typeof o === t,
      zJ: (x0,x1) => x0.openCursor(x1),
      zK: (x0,x1) => ({kind: x0,table: x1}),
      zL: (x0,x1,x2) => x0.sqlite3_column_int64(x1,x2),
      zM: x0 => x0.storage,
      zN: (x0,x1) => x0.createObjectStore(x1),
      zO: x0 => x0.URL,
      zP: (x0,x1) => { x0.type = x1 },
      zQ: () => globalThis._flutter,

    };

    const baseImports = {
      _: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
