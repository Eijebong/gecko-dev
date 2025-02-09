/* -*- Mode: IDL; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/.
 */

/**
 * A collection of static utility methods that are only exposed to Chrome. This
 * interface is not exposed in workers, while ThreadSafeChromeUtils is.
 */
[ChromeOnly, Exposed=(Window,System)]
interface ChromeUtils : ThreadSafeChromeUtils {
  /**
   * A helper that converts OriginAttributesDictionary to a opaque suffix string.
   *
   * @param originAttrs       The originAttributes from the caller.
   */
  static ByteString
  originAttributesToSuffix(optional OriginAttributesDictionary originAttrs);

  /**
   * Returns true if the members of |originAttrs| match the provided members
   * of |pattern|.
   *
   * @param originAttrs       The originAttributes under consideration.
   * @param pattern           The pattern to use for matching.
   */
  static boolean
  originAttributesMatchPattern(optional OriginAttributesDictionary originAttrs,
                               optional OriginAttributesPatternDictionary pattern);

  /**
   * Returns an OriginAttributesDictionary with values from the |origin| suffix
   * and unspecified attributes added and assigned default values.
   *
   * @param origin            The origin URI to create from.
   * @returns                 An OriginAttributesDictionary with values from
   *                          the origin suffix and unspecified attributes
   *                          added and assigned default values.
   */
  [Throws]
  static OriginAttributesDictionary
  createOriginAttributesFromOrigin(DOMString origin);

  /**
   * Returns an OriginAttributesDictionary that is a copy of |originAttrs| with
   * unspecified attributes added and assigned default values.
   *
   * @param originAttrs       The origin attributes to copy.
   * @returns                 An OriginAttributesDictionary copy of |originAttrs|
   *                          with unspecified attributes added and assigned
   *                          default values.
   */
  static OriginAttributesDictionary
  fillNonDefaultOriginAttributes(optional OriginAttributesDictionary originAttrs);

  /**
   * Returns true if the 2 OriginAttributes are equal.
   */
  static boolean
  isOriginAttributesEqual(optional OriginAttributesDictionary aA,
                          optional OriginAttributesDictionary aB);

  /**
   * Loads and compiles the script at the given URL and returns an object
   * which may be used to execute it repeatedly, in different globals, without
   * re-parsing.
   */
  [NewObject, Throws]
  static Promise<PrecompiledScript>
  compileScript(DOMString url, optional CompileScriptOptionsDictionary options);

  /**
   * Waive Xray on a given value. Identity op for primitives.
   */
  [Throws]
  static any waiveXrays(any val);

  /**
   * Strip off Xray waivers on a given value. Identity op for primitives.
   */
  [Throws]
  static any unwaiveXrays(any val);

  /**
   * Gets the name of the JSClass of the object.
   *
   * if |unwrap| is true, all wrappers are unwrapped first. Unless you're
   * specifically trying to detect whether the object is a proxy, this is
   * probably what you want.
   */
  static DOMString getClassName(object obj, optional boolean unwrap = true);

  /**
   * Clones the properties of the given object into a new object in the given
   * target compartment (or the caller compartment if no target is provided).
   * Property values themeselves are not cloned.
   *
   * Ignores non-enumerable properties, properties on prototypes, and properties
   * with getters or setters.
   */
  [Throws]
  static object shallowClone(object obj, optional object? target = null);

  /**
   * Dispatches the given callback to the main thread when it would be
   * otherwise idle. Similar to Window.requestIdleCallback, but not bound to a
   * particular DOM windw.
   */
  [Throws]
  static void idleDispatch(IdleRequestCallback callback,
                           optional IdleRequestOptions options);
};

/**
 * Used by principals and the script security manager to represent origin
 * attributes. The first dictionary is designed to contain the full set of
 * OriginAttributes, the second is used for pattern-matching (i.e. does this
 * OriginAttributesDictionary match the non-empty attributes in this pattern).
 *
 * IMPORTANT: If you add any members here, you need to do the following:
 * (1) Add them to both dictionaries.
 * (2) Update the methods on mozilla::OriginAttributes, including equality,
 *     serialization, deserialization, and inheritance.
 * (3) Update the methods on mozilla::OriginAttributesPattern, including matching.
 */
dictionary OriginAttributesDictionary {
  unsigned long appId = 0;
  unsigned long userContextId = 0;
  boolean inIsolatedMozBrowser = false;
  unsigned long privateBrowsingId = 0;
  DOMString firstPartyDomain = "";
};
dictionary OriginAttributesPatternDictionary {
  unsigned long appId;
  unsigned long userContextId;
  boolean inIsolatedMozBrowser;
  unsigned long privateBrowsingId;
  DOMString firstPartyDomain;
};

dictionary CompileScriptOptionsDictionary {
  /**
   * The character set from which to decode the script.
   */
  DOMString charset = "utf-8";

  /**
   * If true, certain parts of the script may be parsed lazily, the first time
   * they are used, rather than eagerly parsed at load time.
   */
  boolean lazilyParse = false;

  /**
   * If true, the script will be compiled so that its last expression will be
   * returned as the value of its execution. This makes certain types of
   * optimization impossible, and disables the JIT in many circumstances, so
   * should not be used when not absolutely necessary.
   */
  boolean hasReturnValue = false;
};
