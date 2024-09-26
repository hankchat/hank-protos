// Customizations from hank-protos/lib.Customizations.rs
pub use hank::*;

// @TODO need to do the deserializer too
impl serde::ser::Serialize for crate::access_check::AccessCheckChain {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::ser::Serializer,
    {
        use serde::ser::SerializeStruct as _;
        let mut state = serializer.serialize_struct("AccessCheckChain", 2)?;
        state.serialize_field(
            "operator",
            crate::access_check::access_check_chain::Operator::try_from(self.operator)
                .expect("invalid operator")
                .as_str_name(),
        )?;
        state.serialize_field("checks", &self.checks)?;

        state.end()
    }
}

#[cfg(test)]
mod tests {
    use super::access_check::access_check_chain::{access_check::Kind, AccessCheck, Operator};
    use super::access_check::AccessCheckChain;

    #[test]
    fn test_name() {
        let chain = AccessCheckChain {
            operator: Operator::Or as i32,
            checks: vec![
                AccessCheck {
                    kind: Some(Kind::User("1231231213".into())),
                },
                AccessCheck {
                    kind: Some(Kind::Role("OGs".into())),
                },
            ],
        };
        let json = serde_json::to_string_pretty(&chain).unwrap();
        println!("{}", json);
    }
}
