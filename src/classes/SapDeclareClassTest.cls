@isTest
private class SapDeclareClassTest {
    static testMethod void testMethod1() {
        Test.startTest();

        String ss = '';
        //SapApprovalEnum
        ss = SapApprovalEnum.ABNORMALQUALITY;
        ss = SapApprovalEnum.ADVANCECHARGE;
        ss = SapApprovalEnum.ASSETPURCHASE;
        ss = SapApprovalEnum.BUSINESSTRAVEL;
        ss = SapApprovalEnum.COSTCENTERSEND;

        SapContentOfReturnArgs cls2 = new SapContentOfReturnArgs();
        cls2.main = null;
        cls2.details = null;

        SapCustomerContractMaterial cls3 = new SapCustomerContractMaterial();
        cls3.status = '1';
        cls3.message = '';
        cls3.content = null;
        SapCustomerContractMaterial.CustomerContract cls31 = new SapCustomerContractMaterial.CustomerContract();
        cls31.main = null;
        cls31.details = null;
        SapCustomerContractMaterial.MaterialList cls32 = new SapCustomerContractMaterial.MaterialList();
        cls32.Protocol_Price = '';
        cls32.Customer_Material_Code = '';
        cls32.Material_Name = '';
        cls32.Order_Quantity = '';
        cls32.Remark = '';
        cls32.Material_Code = '';
        cls32.Stock_Quantity = '';
        SapCustomerContractMaterial.ProtocolContract cls33 = new SapCustomerContractMaterial.ProtocolContract();
        cls33.Customer_Code = '';
        cls33.Contract_Name = '';
        cls33.End_Date = '';
        cls33.Customer_Name = '';
        cls33.Start_Date = '';
        SapCustomerContractMaterial.ProtocolContractMaterial cls34 = new SapCustomerContractMaterial.ProtocolContractMaterial();
        cls34.materials = null;

        SapMaterialCertificate cls4 = new SapMaterialCertificate();
        cls4.status = '';
        cls4.message = '';
        cls4.content = null;
        SapMaterialCertificate.HeatAnalyzeAndSpecification cls41 = new SapMaterialCertificate.HeatAnalyzeAndSpecification();
        cls41.S = '';
        cls41.Mn = '';
        cls41.Material_Standard = '';
        cls41.Si = '';
        cls41.P = '';
        cls41.Raw_Material_Spec = '';
        cls41.Ni = '';
        cls41.Cr = '';
        cls41.C = '';
        cls41.Batch_NO = '';
        cls41.Mo = '';
        cls41.N = '';
        cls41.Heat_Number = '';
        SapMaterialCertificate.MaterialCertificate cls42 = new SapMaterialCertificate.MaterialCertificate();
        cls42.Template_Name = '';
        cls42.Certificate_NO = '';
        cls42.Customer_Name = '';
        cls42.Stocking_NO = '';
        cls42.Batch_NO = '';
        cls42.Customer_Order_NO = '';
        cls42.Customer_Material_NO = '';
        cls42.KL_Material_NO = '';
        cls42.Material_Description = '';
        cls42.Material_Type = '';
        cls42.Date_of_Certificate = '';
        cls42.Voucher_NO = '';
        cls42.Quantity = '';
        cls42.Quantity_Unit = '';
        cls42.Order_NO = '';
        cls42.DT_Code = '';
        cls42.Job_NO = '';
        cls42.Material_Description_EN = '';
        cls42.heats = null;
        cls42.mechanicals = null;
        cls42.continuations = null;
        cls42.others = null;
        SapMaterialCertificate.MechanicalTest cls43 = new SapMaterialCertificate.MechanicalTest();
        cls43.Heat_Number = '';
        cls43.Yield02 = '';
        cls43.Rp02 = '';
        cls43.Yield10 = '';
        cls43.Rp10 = '';
        cls43.Tensile = '';
        cls43.Strength = '';
        cls43.Width_of_Gage_Length = '';
        cls43.Hardness = '';
        cls43.Reduction_of_Area = '';
        cls43.Elongation = '';
        cls43.Raw_Material_Spec = '';
        cls43.Batch_NO = '';
        SapMaterialCertificate.MechanicalTestContinuation cls44 = new SapMaterialCertificate.MechanicalTestContinuation();
        cls44.Heat_Number = '';
        cls44.Impact_Test = '';
        cls44.Eddy_Current_Test = '';
        cls44.Flaring_Flange_Test = '';
        cls44.Flattening_Reverse_Flattening = '';
        cls44.Bend_Reverse_Bend_Test = '';
        cls44.Intergranular_Corrosion_Test = '';
        cls44.Raw_Material_Spec = '';
        cls44.Batch_NO = '';
        SapMaterialCertificate.OtherAnalysisAndInspection cls45 = new SapMaterialCertificate.OtherAnalysisAndInspection();
        cls45.Visual_Dimensional_Test = '';
        cls45.Material_Identification = '';
        cls45.Ra_Max_Value = '';
        cls45.Raw_Material_Spec = '';
        cls45.Batch_NO = '';
        //SapOperateEnum
        ss = SapOperateEnum.FROZEN;
        ss = SapOperateEnum.INSERTED;
        ss = SapOperateEnum.UPDATED;

        SapWebServiceReturnResult cls6 = new SapWebServiceReturnResult();
        cls6.SAPID = '';
        cls6.SFID = '';
        cls6.message = '';
        cls6.status = '';

        Test.stopTest();
    }
}