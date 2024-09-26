// Customizations from hank-protos/lib.Customizations.rs
pub use hank::*;

impl serde::ser::Serialize for crate::access_check::AccessCheckChain {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::ser::Serializer,
    {
        use serde::ser::SerializeStruct as _;
        let mut state = serializer.serialize_struct("AccessCheckChain", 1)?;
        state.serialize_field(
            crate::access_check::AccessCheckOperator::try_from(self.operator)
                .expect("invalid operator")
                .as_str_name(),
            &self.checks,
        )?;

        state.end()
    }
}

impl<'de> serde::de::Deserialize<'de> for access_check::AccessCheckChain {
    fn deserialize<D: serde::de::Deserializer<'de>>(d: D) -> Result<Self, D::Error> {
        let d: std::collections::BTreeMap<String, Vec<access_check::AccessCheck>> =
            std::collections::BTreeMap::deserialize(d)?;

        let (operator, checks) = d.first_key_value().expect("invalid access chain format");
        Ok(access_check::AccessCheckChain {
            operator: access_check::AccessCheckOperator::from_str_name(operator)
                .expect("invalid access chain operator")
                .into(),
            checks: checks.to_vec(),
        })
    }
}

#[cfg(test)]
mod tests {
    use super::access_check::AccessCheckChain;
    use super::access_check::{access_check::Kind, AccessCheck, AccessCheckOperator};

    #[test]
    fn test_name() {
        let chain = AccessCheckChain {
            operator: AccessCheckOperator::Or as i32,
            checks: vec![
                AccessCheck {
                    kind: Some(Kind::User("1231231213".into())),
                },
                AccessCheck {
                    kind: Some(Kind::Role("OGs".into())),
                },
            ],
        };
        let se_chain = serde_json::to_string_pretty(&chain).unwrap();
        println!("{}", se_chain);
        let de_chain: AccessCheckChain = serde_json::from_str(&se_chain).unwrap();
        dbg!(&de_chain);
    }
}
