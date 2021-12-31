/**
 * ROSIDL parser witten in D.
 *
 * Examples
 * ----------
 * // msg
 * auto msg = "pkgname/msg/MyMessage.idl".readText.parseAsMessage();
 * // srv
 * auto srv = "pkgname/srv/MyService.idl".readText.parseAsService();
 * // action
 * auto action = "pkgname/srv/MyAction.idl".readText.parseAsAction();
 * ----------
 */
module rosidl_parser;

public import rosidl_parser.definition;
public import rosidl_parser.parser;
