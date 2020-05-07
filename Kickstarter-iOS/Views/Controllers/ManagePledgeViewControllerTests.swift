@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class ManagePledgeViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testView_CurrentUser_IsBacker() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      let user = User.template
        |> User.lens.id .~ 1
        |> User.lens.avatar.small .~ ""

      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true
      let backing = Backing.template

        |> Backing.lens.reward .~ reward
      let backedProject = Project.cosmicSurgery
        |> Project.lens.personalization.backing .~ backing

      let envelope = ManagePledgeViewBackingEnvelope.template
        |> \.backing.sequence .~ 10
        |> \.backing.pledgedOn .~ TimeInterval(1_475_361_315)
        |> \.backing.amount .~ Money(amount: "10.0", currency: .gbp, symbol: "£")
        |> \.backing.backer.uid .~ user.id
        |> \.backing.backer.name .~ "Blob"

      let mockService = MockService(fetchManagePledgeViewBackingResult: .success(envelope))

      withEnvironment(apiService: mockService, currentUser: user, language: language) {
        let controller = ManagePledgeViewController.instantiate()
        controller.configureWith(project: backedProject)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_200

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_NoReward_ApplePay() {
    let language = Language.en
    let device = Device.phone4_7inch
    let user = User.template
      |> User.lens.id .~ 1
      |> User.lens.avatar.small .~ ""

    withEnvironment(currentUser: user, language: language) {
      let reward = Reward.noReward

      let backing = Backing.template
        |> Backing.lens.amount .~ 10
        |> Backing.lens.locationId .~ nil
        |> Backing.lens.shippingAmount .~ nil
        |> Backing.lens.rewardId .~ nil
        |> Backing.lens.reward .~ reward
        |> Backing.lens.paymentSource .~ Backing.PaymentSource.applePay

      let backedProject = Project.cosmicSurgery
        |> Project.lens.personalization.backing .~ backing

      // TODO: Configure ManagePledgePaymentMethodView to be configured with this Backing
      let envelope = ManagePledgeViewBackingEnvelope.template
        |> \.backing.sequence .~ 10
        |> \.backing.pledgedOn .~ TimeInterval(1_475_361_315)
        |> \.backing.amount .~ Money(amount: "10.0", currency: .gbp, symbol: "£")
        |> \.backing.backer.uid .~ user.id
        |> \.backing.backer.name .~ "Blob"
        |> \.backing.creditCard .~ ManagePledgeViewBackingEnvelope.Backing.CreditCard(
          expirationDate: "2019-10-31",
          id: "1",
          lastFour: "1111",
          paymentType: .applePay,
          type: .visa
        )

      let mockService = MockService(fetchManagePledgeViewBackingResult: .success(envelope))

      withEnvironment(apiService: mockService, currentUser: user, language: language) {
        let controller = ManagePledgeViewController.instantiate()
        controller.configureWith(project: backedProject)
        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_GooglePay() {
    let language = Language.en
    let device = Device.phone4_7inch
    let user = User.template
      |> User.lens.id .~ 1
      |> User.lens.avatar.small .~ ""

    withEnvironment(currentUser: user, language: language) {
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      let backing = Backing.template
        |> Backing.lens.reward .~ reward
        |> Backing.lens.paymentSource .~ Backing.PaymentSource.googlePay

      let backedProject = Project.cosmicSurgery
        |> Project.lens.personalization.backing .~ backing

      // TODO: Configure ManagePledgePaymentMethodView to be configured with this Backing
      let envelope = ManagePledgeViewBackingEnvelope.template
        |> \.backing.sequence .~ 10
        |> \.backing.pledgedOn .~ TimeInterval(1_475_361_315)
        |> \.backing.amount .~ Money(amount: "10.0", currency: .gbp, symbol: "£")
        |> \.backing.backer.uid .~ user.id
        |> \.backing.backer.name .~ "Blob"
        |> \.backing.creditCard .~ ManagePledgeViewBackingEnvelope.Backing.CreditCard(
          expirationDate: "2019-10-31",
          id: "123",
          lastFour: "4111",
          paymentType: .googlePay,
          type: .visa
        )

      let mockService = MockService(fetchManagePledgeViewBackingResult: .success(envelope))

      withEnvironment(apiService: mockService, currentUser: user, language: language) {
        let controller = ManagePledgeViewController.instantiate()
        controller.configureWith(project: backedProject)
        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )
        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ErroredBacking() {
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      let user = User.template
        |> User.lens.id .~ 1
        |> User.lens.avatar.small .~ ""

      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true
      let backing = Backing.template
        |> Backing.lens.status .~ .errored
        |> Backing.lens.reward .~ reward
      let backedProject = Project.cosmicSurgery
        |> Project.lens.personalization.backing .~ backing

      // TODO: update PledgeStatusLabelView to use this backing
      let envelope = ManagePledgeViewBackingEnvelope.template
        |> \.backing.sequence .~ 10
        |> \.backing.pledgedOn .~ TimeInterval(1_475_361_315)
        |> \.backing.amount .~ Money(amount: "10.0", currency: .gbp, symbol: "£")
        |> \.backing.backer.uid .~ user.id
        |> \.backing.backer.name .~ "Blob"
        |> \.backing.status .~ .errored
        |> \.backing.errorReason .~ "Error reason"

      let mockService = MockService(fetchManagePledgeViewBackingResult: .success(envelope))

      withEnvironment(apiService: mockService, currentUser: user, language: language) {
        let controller = ManagePledgeViewController.instantiate()
        controller.configureWith(project: backedProject)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
